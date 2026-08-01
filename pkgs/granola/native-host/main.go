// meet-consent-host bridges Chrome Native Messaging to Granola's local
// newline-delimited JSON socket.
package main

import (
	"bufio"
	"encoding/binary"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log"
	"net"
	"os"
	"strings"
	"time"
)

const (
	defaultSocketPath = "/tmp/granola-meet-consent.sock"
	maxBrowserMessage = 64 * 1024 * 1024
	maxGranolaMessage = 1024 * 1024
)

func main() {
	log.SetFlags(log.LstdFlags | log.Lmicroseconds)
	log.SetPrefix("meet-consent-host: ")

	socketPath := os.Getenv("GRANOLA_MEET_CONSENT_SOCKET")
	if socketPath == "" {
		socketPath = defaultSocketPath
	}

	connection, err := net.DialTimeout("unix", socketPath, 2*time.Second)
	if err != nil {
		log.Printf("cannot connect to Granola at %s: %v", socketPath, err)
		os.Exit(1)
	}
	defer connection.Close()

	if err := bridge(os.Stdin, os.Stdout, connection); err != nil && !isNormalShutdown(err) {
		log.Printf("bridge stopped: %v", err)
		os.Exit(1)
	}
}

func bridge(browserIn io.Reader, browserOut io.Writer, granola net.Conn) error {
	errorsFromPump := make(chan error, 2)

	go func() {
		errorsFromPump <- browserToGranola(browserIn, granola)
	}()
	go func() {
		errorsFromPump <- granolaToBrowser(granola, browserOut)
	}()

	err := <-errorsFromPump
	_ = granola.Close()
	return err
}

func browserToGranola(browser io.Reader, granola io.Writer) error {
	for {
		message, err := readNativeMessage(browser, maxBrowserMessage)
		if err != nil {
			return fmt.Errorf("read from Chrome: %w", err)
		}
		if err := writeJSONLine(granola, message); err != nil {
			return fmt.Errorf("write to Granola: %w", err)
		}
	}
}

func granolaToBrowser(granola io.Reader, browser io.Writer) error {
	reader := bufio.NewReaderSize(granola, maxGranolaMessage+1)
	for {
		message, err := readJSONLine(reader, maxGranolaMessage)
		if err != nil {
			return fmt.Errorf("read from Granola: %w", err)
		}
		if err := writeNativeMessage(browser, message); err != nil {
			return fmt.Errorf("write to Chrome: %w", err)
		}
	}
}

func readNativeMessage(reader io.Reader, maximum uint32) ([]byte, error) {
	var length uint32
	if err := binary.Read(reader, binary.LittleEndian, &length); err != nil {
		return nil, err
	}
	if length == 0 {
		return nil, errors.New("empty native message")
	}
	if length > maximum {
		return nil, fmt.Errorf("native message is %d bytes; maximum is %d", length, maximum)
	}

	message := make([]byte, length)
	if _, err := io.ReadFull(reader, message); err != nil {
		return nil, err
	}
	if !json.Valid(message) {
		return nil, errors.New("native message is not valid JSON")
	}
	return message, nil
}

func writeNativeMessage(writer io.Writer, message []byte) error {
	message = []byte(strings.TrimSpace(string(message)))
	if len(message) == 0 || !json.Valid(message) {
		return errors.New("Granola message is not valid JSON")
	}
	if len(message) > maxGranolaMessage {
		return fmt.Errorf("Granola message is %d bytes; maximum is %d", len(message), maxGranolaMessage)
	}

	if err := binary.Write(writer, binary.LittleEndian, uint32(len(message))); err != nil {
		return err
	}
	_, err := writer.Write(message)
	return err
}

func readJSONLine(reader *bufio.Reader, maximum int) ([]byte, error) {
	line, err := reader.ReadSlice('\n')
	if errors.Is(err, bufio.ErrBufferFull) || len(line) > maximum {
		return nil, fmt.Errorf("Granola message exceeds %d bytes", maximum)
	}
	if err != nil {
		return nil, err
	}

	line = []byte(strings.TrimSpace(string(line)))
	if len(line) == 0 {
		return nil, errors.New("Granola sent an empty message")
	}
	if !json.Valid(line) {
		return nil, errors.New("Granola message is not valid JSON")
	}
	return line, nil
}

func writeJSONLine(writer io.Writer, message []byte) error {
	if !json.Valid(message) {
		return errors.New("Chrome message is not valid JSON")
	}
	if _, err := writer.Write(message); err != nil {
		return err
	}
	_, err := writer.Write([]byte{'\n'})
	return err
}

func isNormalShutdown(err error) bool {
	return errors.Is(err, io.EOF) ||
		errors.Is(err, net.ErrClosed) ||
		strings.Contains(err.Error(), "use of closed network connection") ||
		strings.Contains(err.Error(), "broken pipe")
}

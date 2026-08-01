package main

import (
	"bufio"
	"bytes"
	"encoding/binary"
	"io"
	"net"
	"testing"
)

func TestBrowserToGranola(t *testing.T) {
	message := []byte(`{"type":"granola:event","event":"active-speaker-changed"}`)
	var framed bytes.Buffer
	if err := binary.Write(&framed, binary.LittleEndian, uint32(len(message))); err != nil {
		t.Fatal(err)
	}
	framed.Write(message)

	var got bytes.Buffer
	err := browserToGranola(&framed, &got)
	if err != io.EOF && !isNormalShutdown(err) {
		t.Fatalf("browserToGranola returned %v", err)
	}
	if want := string(message) + "\n"; got.String() != want {
		t.Fatalf("got %q, want %q", got.String(), want)
	}
}

func TestGranolaToBrowser(t *testing.T) {
	message := []byte(`{"type":"granola:status","connected":true}`)
	var got bytes.Buffer
	err := granolaToBrowser(bytes.NewReader(append(message, '\n')), &got)
	if err != io.EOF && !isNormalShutdown(err) {
		t.Fatalf("granolaToBrowser returned %v", err)
	}

	lengthBytes := got.Next(4)
	if len(lengthBytes) != 4 {
		t.Fatalf("got %d length bytes, want 4", len(lengthBytes))
	}
	if length := binary.LittleEndian.Uint32(lengthBytes); length != uint32(len(message)) {
		t.Fatalf("got length %d, want %d", length, len(message))
	}
	if payload := got.String(); payload != string(message) {
		t.Fatalf("got %q, want %q", payload, message)
	}
}

func TestBridgeIsDuplex(t *testing.T) {
	bridgeSide, serverSide := net.Pipe()
	defer serverSide.Close()

	chromeMessage := []byte(`{"type":"granola:log","event":"test"}`)
	var chromeInput bytes.Buffer
	if err := binary.Write(&chromeInput, binary.LittleEndian, uint32(len(chromeMessage))); err != nil {
		t.Fatal(err)
	}
	chromeInput.Write(chromeMessage)

	var chromeOutput bytes.Buffer
	done := make(chan error, 1)
	go func() {
		done <- bridge(&chromeInput, &chromeOutput, bridgeSide)
	}()

	line, err := bufio.NewReader(serverSide).ReadString('\n')
	if err != nil {
		t.Fatal(err)
	}
	if want := string(chromeMessage) + "\n"; line != want {
		t.Fatalf("got socket line %q, want %q", line, want)
	}

	granolaMessage := []byte(`{"type":"granola:heartbeat","recording":false}`)
	if _, err := serverSide.Write(append(granolaMessage, '\n')); err != nil {
		t.Fatal(err)
	}
	_ = serverSide.Close()
	<-done

	if chromeOutput.Len() < 4 {
		t.Fatalf("Chrome output was only %d bytes", chromeOutput.Len())
	}
	length := binary.LittleEndian.Uint32(chromeOutput.Next(4))
	if length != uint32(len(granolaMessage)) {
		t.Fatalf("got length %d, want %d", length, len(granolaMessage))
	}
	if payload := chromeOutput.String(); payload != string(granolaMessage) {
		t.Fatalf("got %q, want %q", payload, granolaMessage)
	}
}

func TestRejectsInvalidJSON(t *testing.T) {
	message := []byte(`not-json`)
	var framed bytes.Buffer
	if err := binary.Write(&framed, binary.LittleEndian, uint32(len(message))); err != nil {
		t.Fatal(err)
	}
	framed.Write(message)

	if _, err := readNativeMessage(&framed, maxBrowserMessage); err == nil {
		t.Fatal("readNativeMessage accepted invalid JSON")
	}
}

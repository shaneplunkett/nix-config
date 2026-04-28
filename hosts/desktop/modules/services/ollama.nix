{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    # ROCm build — uses the 7900-series GPU for inference. Faster summaries,
    # frees the CPU for whisperx's parallel work during meetscribe runs.
    package = pkgs.ollama-rocm;
    host = "127.0.0.1";
    port = 11434;
  };
}

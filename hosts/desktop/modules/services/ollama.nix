{ pkgs, ... }:
{
  services.ollama = {
    enable = true;
    # CPU build for v1 — works on the 7800X3D for small models.
    # Switch to `pkgs.ollama-rocm` once we've validated meetscribe end-to-end
    # and want GPU acceleration on the 7900-series card.
    package = pkgs.ollama;
    host = "127.0.0.1";
    port = 11434;
  };
}

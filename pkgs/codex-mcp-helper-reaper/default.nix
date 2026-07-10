{
  lib,
  rustPlatform,
  src,
}:

rustPlatform.buildRustPackage {
  pname = "codex-mcp-helper-reaper";
  version = "0.1.0";

  inherit src;

  cargoHash = "sha256-57dDT1OXHavUQY1OP9cqnA7vMZ8E52bo8ZQxZAZydZY=";

  meta = {
    description = "Reap stale duplicate and orphaned Codex MCP helper generations";
    homepage = "https://github.com/ilysenko/codex-desktop-linux";
    license = lib.licenses.mit;
    mainProgram = "codex-mcp-helper-reaper";
    platforms = lib.platforms.linux;
  };
}

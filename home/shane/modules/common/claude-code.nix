{ pkgs, ... }:
let
  claudeNodejs = pkgs.nodejs;
in
{
  programs.claude-code = {
    enable = true;
    package = pkgs.claude-code;

    settings = {
      theme = "dark-ansi";

      statusLine = "${claudeNodejs}/bin/npx ccstatusline@latest";

      hooks = {
        PreCompact = [
          {
            hooks = [
              {
                type = "command";
                command = "echo 'COMPACTION INSTRUCTIONS: Preserve all architectural decisions, file paths modified, key constraints, current task state, and user preferences. Summarize code changes with before/after context. Keep exact error messages and their resolutions. Maintain the full list of files created or modified.'";
              }
            ];
          }
        ];
        SessionStart = [
          {
            matcher = "compact";
            hooks = [
              {
                type = "command";
                command = "echo '--- Post-compaction context reload ---' && echo \"Git branch: $(git branch --show-current 2>/dev/null || echo N/A)\" && echo 'Recent commits:' && git log --oneline -5 2>/dev/null || true && echo 'Modified files:' && git diff --name-only 2>/dev/null || true";
              }
            ];
          }
        ];
      };
    };
  };
}

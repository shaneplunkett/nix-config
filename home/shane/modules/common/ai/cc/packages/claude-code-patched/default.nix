# claude-code-patched — pkgs.claude-code with tweakcc-fixed applied at build
# time. Pairs with skrabe/lobotomized-claude-code for slimmer system prompts
# and per-turn injections tuned for Opus 4.7.
#
# The patch lives in preFixup so it runs AFTER installPhase (which puts the
# original Bun binary at $out/bin/.claude-wrapped) but BEFORE autoPatchelfHook
# in fixupPhase: LIEF can't parse the autoPatchelf'd ELF because the added
# LOAD segment for the longer Nix-store interpreter path confuses its program-
# header walk and segfaults during native-binary extraction.
#
# Adapted from github.com/typedrat/nix-config/packages/claude-code-patched (MIT).
{
  lib,
  stdenv,
  darwin,
  fetchFromGitHub,
  claude-code,
  tweakcc-fixed,
  jq,
  nix-update-script,
  # User-supplied tweakcc config — tracked alongside this package so tweaks
  # are reproducible across hosts. Edit ./config.json to change knobs.
  tweakccConfig ? ./config.json,
}:
let
  # skrabe/lobotomized-claude-code: slim, less-CAPS-heavy rewrites of Claude
  # Code's system prompts and per-turn injections tuned for Opus 4.7. Not
  # actually lobotomy — strips over-the-top prompt engineering and shrinks
  # the always-injected fragments. Bump rev + hash via nurl on update.
  promptOverrides = fetchFromGitHub {
    owner = "skrabe";
    repo = "lobotomized-claude-code";
    rev = "4bb5dbb81d743107da5abadd026691c9d226bc02";
    hash = "sha256-uU8wRE3NwK9LFu8UG2kkwAU9/xM/0IbRbAacRlYRTXc=";
  };

  # tweakcc-fixed's regex patches are pinned to specific CC minified shapes
  # (see tweakcc-fixed.nix — regex updates land per CC version). If
  # nixpkgs's claude-code drifts ahead of the ccVersion captured in
  # config.json, the patch step can silently produce a partial-patch
  # binary. Fail at eval time to force a deliberate ccVersion bump.
  configCcVersion = (builtins.fromJSON (builtins.readFile tweakccConfig)).ccVersion;
in
assert lib.assertMsg (configCcVersion == claude-code.version) ''
  claude-code-patched: ccVersion drift.
    config.json ccVersion: ${configCcVersion}
    pkgs.claude-code:      ${claude-code.version}
  Update config.json#ccVersion and verify tweakcc-fixed regex patches still
  apply for the new CC version (see skrabe/tweakcc-fixed CHANGELOG).
'';
claude-code.overrideAttrs (prev: {
  pname = "claude-code-patched";

  # tweakcc rewrites bytes inside the signed Mach-O text/data segments;
  # macOS then SIGKILLs the binary at launch because the signature no
  # longer matches. autoSignDarwinBinariesHook registers a postFixupHook
  # that re-signs every output file, running after our preFixup patch
  # step lands. Without it, versionCheckPhase sees an empty `claude
  # --version` (exit 137) and the build fails late.
  nativeBuildInputs = prev.nativeBuildInputs ++ [
    tweakcc-fixed
    jq
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin darwin.autoSignDarwinBinariesHook;

  preFixup = (prev.preFixup or "") + ''
    # Stage tweakcc's expected HOME / config layout in the sandbox.
    export TWEAKCC_CONFIG_DIR="$TMPDIR/tweakcc"
    export HOME="$TMPDIR/home"
    mkdir -p "$TWEAKCC_CONFIG_DIR" "$HOME"

    install -m 0644 ${tweakccConfig} "$TWEAKCC_CONFIG_DIR/config.json"
    # tweakcc seeds defaults into system-prompts/ and system-reminders/
    # on first --apply, so they must be writable — symlinks back to the
    # immutable prompt-overrides source are insufficient.
    cp -RL ${promptOverrides}/system-prompts  "$TWEAKCC_CONFIG_DIR/system-prompts"
    cp -RL ${promptOverrides}/system-reminders "$TWEAKCC_CONFIG_DIR/system-reminders"
    chmod -R u+w "$TWEAKCC_CONFIG_DIR/system-prompts" "$TWEAKCC_CONFIG_DIR/system-reminders"

    # Resolve ''${X_TOOL_NAME} template placeholders in lobotomized's prompts.
    # Upstream bug: lobotomized declares these as substitution variables in
    # frontmatter expecting tweakcc-fixed to resolve them at apply time, but
    # the substitution layer doesn't actually implement them — the literal
    # template literals end up in the bundled JS, which then ReferenceErrors
    # when CC concatenates them inside a JS template literal context (most
    # notably when building subagent system prompts → agent dispatch dies).
    # Substitute each TOOL_NAME variable with the canonical CC tool name
    # before tweakcc applies the overrides. ''${} is the Nix escape for a
    # literal ''${; { } themselves aren't special in sed BRE.
    find "$TWEAKCC_CONFIG_DIR/system-prompts" "$TWEAKCC_CONFIG_DIR/system-reminders" -type f -name '*.md' -print0 \
      | xargs -0 sed -i \
        -e 's/''${WRITE_TOOL_NAME}/Write/g' \
        -e 's/''${EDIT_TOOL_NAME}/Edit/g' \
        -e 's/''${MULTI_EDIT_TOOL_NAME}/MultiEdit/g' \
        -e 's/''${READ_TOOL_NAME}/Read/g' \
        -e 's/''${BASH_TOOL_NAME}/Bash/g' \
        -e 's/''${GREP_TOOL_NAME}/Grep/g' \
        -e 's/''${GLOB_TOOL_NAME}/Glob/g' \
        -e 's/''${TODOWRITE_TOOL_NAME}/TodoWrite/g' \
        -e 's/''${TODO_WRITE_TOOL_NAME}/TodoWrite/g' \
        -e 's/''${TASK_TOOL_NAME}/Task/g' \
        -e 's/''${AGENT_TOOL_NAME}/Agent/g' \
        -e 's/''${ASK_USER_QUESTION_TOOL_NAME}/AskUserQuestion/g' \
        -e 's/''${EXIT_PLAN_MODE_TOOL_NAME}/ExitPlanMode/g' \
        -e 's/''${ENTER_PLAN_MODE_TOOL_NAME}/EnterPlanMode/g' \
        -e 's/''${ENTER_WORKTREE_TOOL_NAME}/EnterWorktree/g' \
        -e 's/''${EXIT_WORKTREE_TOOL_NAME}/ExitWorktree/g' \
        -e 's/''${CRON_CREATE_TOOL_NAME}/CronCreate/g' \
        -e 's/''${CRON_DELETE_TOOL_NAME}/CronDelete/g' \
        -e 's/''${CRON_LIST_TOOL_NAME}/CronList/g' \
        -e 's/''${WEB_FETCH_TOOL_NAME}/WebFetch/g' \
        -e 's/''${WEB_SEARCH_TOOL_NAME}/WebSearch/g' \
        -e 's/''${NOTEBOOK_EDIT_TOOL_NAME}/NotebookEdit/g' \
        -e 's/''${SHARE_ONBOARDING_GUIDE_TOOL_NAME}/ShareOnboardingGuide/g' \
        -e 's/''${SCHEDULE_WAKEUP_TOOL_NAME}/ScheduleWakeup/g' \
        -e 's/''${MONITOR_TOOL_NAME}/Monitor/g' \
        -e 's/''${PUSH_NOTIFICATION_TOOL_NAME}/PushNotification/g' \
        -e 's/''${REMOTE_TRIGGER_TOOL_NAME}/RemoteTrigger/g' \
        -e 's/''${TOOL_SEARCH_TOOL_NAME}/ToolSearch/g' \
        -e 's/''${SKILL_TOOL_NAME}/Skill/g' \
        -e 's/''${LIST_MCP_RESOURCES_TOOL_NAME}/ListMcpResourcesTool/g' \
        -e 's/''${READ_MCP_RESOURCE_TOOL_NAME}/ReadMcpResourceTool/g'

    # Scrub the captured config's installation pointer and applied flag
    # so tweakcc targets the binary in *this* derivation and actually
    # re-runs the patches.
    jq 'del(.ccInstallationPath, .ccInstallationDir) | .changesApplied = false' \
      "$TWEAKCC_CONFIG_DIR/config.json" > "$TWEAKCC_CONFIG_DIR/config.json.new"
    mv "$TWEAKCC_CONFIG_DIR/config.json.new" "$TWEAKCC_CONFIG_DIR/config.json"

    # wrapProgram already moved the original binary to .claude-wrapped in
    # installPhase. Patch that one — the outer `claude` is the
    # makeBinaryWrapper shim and gets autoPatchelf'd separately.
    export TWEAKCC_CC_INSTALLATION_PATH="$out/bin/.claude-wrapped"
    ${lib.getExe tweakcc-fixed} --apply
  '';

  passthru = (prev.passthru or { }) // {
    unpatched = claude-code;
    promptOverridesSrc = promptOverrides;
    updateScript = nix-update-script { attrPath = "claude-code"; };
  };

  meta = prev.meta // {
    description = "Claude Code with skrabe/lobotomized-claude-code system-prompt overrides applied via tweakcc-fixed";
  };
})

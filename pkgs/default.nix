{
  pkgs,
  inputs,
  rootPath,
}:
let
  agSkillsInstallScript = rootPath + /home/shane/modules/common/ai/cc/install-ag-ai-skills.sh;
in
{
  ag-ai-skills-built = pkgs.callPackage ./ag-ai-skills-built {
    src = inputs.ag-ai-skills;
    installScript = agSkillsInstallScript;
  };
  ag-ai-skills-built-codex = pkgs.callPackage ./ag-ai-skills-built {
    src = inputs.ag-ai-skills;
    installScript = agSkillsInstallScript;
    normaliseFrontmatter = true;
  };
  aikido-mcp = pkgs.callPackage ./aikido-mcp { };
  bluebubbles-themed = pkgs.callPackage ./bluebubbles-themed { };
  claude-code = pkgs.callPackage ./claude-code { };
  claude-code-patched = pkgs.callPackage ./claude-code-patched { };
  claude-plugins-official = pkgs.callPackage ./claude-plugins-official { };
  codex-patched = pkgs.callPackage ./codex-patched { };
  orca-slicer-bambulab = pkgs.callPackage ./orca-slicer-bambulab { };
  tweakcc-fixed = pkgs.callPackage ./tweakcc-fixed { };
  xcodebuild-nvim = pkgs.callPackage ./xcodebuild-nvim { };
  xero-mcp-server = pkgs.callPackage ./xero-mcp-server { };
}

{
  pkgs,
  inputs,
  rootPath,
  isLinux ? false,
  isX86Linux ? false,
}:
let
  agSkillsInstallScript = rootPath + /home/shane/modules/common/ai/cc/install-ag-ai-skills.sh;
  optionalAttrs = condition: attrs: if condition then attrs else { };
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
  claude-code-latest = pkgs.callPackage ./claude-code-latest { };
  claude-plugins-official = pkgs.callPackage ./claude-plugins-official { };
  codex-patched = pkgs.callPackage ./codex-patched { };
  xcodebuild-nvim = pkgs.callPackage ./xcodebuild-nvim { };
  xero-mcp-server = pkgs.callPackage ./xero-mcp-server { };
}
// optionalAttrs isLinux {
  bluebubbles-themed = pkgs.callPackage ./bluebubbles-themed { };
}
// optionalAttrs isX86Linux {
  orca-slicer-bambulab = pkgs.callPackage ./orca-slicer-bambulab { };
  shadps4-cache-fixed = pkgs.callPackage ./shadps4-cache-fixed { };
  ytmdesktop-bin = pkgs.callPackage ./ytmdesktop-bin { };
}

{ lib, ... }:
let
  c = import ../../theme/colours.nix;
  hex = colour: "#${colour}";
in
{

  programs.opencode.themes.catppuccin-mocha = {
    # UI
    primary = hex c.mauve;
    secondary = hex c.lavender;
    accent = hex c.pink;
    error = hex c.red;
    warning = hex c.peach;
    success = hex c.green;
    info = hex c.sapphire;

    # Text
    text = hex c.text;
    textMuted = hex c.subtext0;

    # Backgrounds
    background = hex c.base;
    backgroundPanel = hex c.mantle;
    backgroundElement = hex c.surface0;

    # Borders
    border = hex c.surface1;
    borderActive = hex c.mauve;
    borderSubtle = hex c.surface0;

    # Diff
    diffAdded = hex c.green;
    diffRemoved = hex c.red;
    diffContext = hex c.subtext0;
    diffHunkHeader = hex c.mauve;
    diffHighlightAdded = hex c.green;
    diffHighlightRemoved = hex c.red;
    diffAddedBg = "#2a3e2e";
    diffRemovedBg = "#3e2a2e";
    diffContextBg = hex c.mantle;
    diffLineNumber = hex c.overlay0;
    diffAddedLineNumberBg = "#2a3e2e";
    diffRemovedLineNumberBg = "#3e2a2e";

    # Markdown
    markdownText = hex c.text;
    markdownHeading = hex c.mauve;
    markdownLink = hex c.sapphire;
    markdownLinkText = hex c.blue;
    markdownCode = hex c.green;
    markdownBlockQuote = hex c.lavender;
    markdownEmph = hex c.pink;
    markdownStrong = hex c.peach;
    markdownHorizontalRule = hex c.surface2;
    markdownListItem = hex c.teal;
    markdownListEnumeration = hex c.teal;
    markdownImage = hex c.sapphire;
    markdownImageText = hex c.blue;
    markdownCodeBlock = hex c.surface0;

    # Syntax
    syntaxComment = hex c.overlay1;
    syntaxKeyword = hex c.mauve;
    syntaxFunction = hex c.blue;
    syntaxVariable = hex c.text;
    syntaxString = hex c.green;
    syntaxNumber = hex c.peach;
    syntaxType = hex c.yellow;
    syntaxOperator = hex c.sky;
    syntaxPunctuation = hex c.overlay2;
  };

  programs.opencode.settings.theme = lib.mkForce "catppuccin-mocha";

}

{ codex }:

codex.overrideAttrs (oldAttrs: {
  pname = "codex-patched";

  patches = (oldAttrs.patches or [ ]) ++ [
    ./codex-vex-markdown-colours.patch
  ];
})

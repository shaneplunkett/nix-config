return {
  cmd = { 'nixd' },
  filetypes = { 'nix' },
  settings = {
    nixd = {
      nixpkgs = {
        expr = 'import <nixpkgs> { }',
      },
      options = {
        nixos = {
          expr = '(builtins.getFlake "/home/wout/.nix").nixosConfigurations.framework.options',
        },
      },
    },
  },
}

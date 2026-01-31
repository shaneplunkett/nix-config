{ pkgs, ... }:
{
  plugins = {
    # Better text objects
    # Examples:
    #  - va)  - [V]isually select [A]round [)]paren
    #  - yinq - [Y]ank [I]nside [N]ext [Q]uote
    #  - ci'  - [C]hange [I]nside [']quote
    mini.ai = {
      enable = true;
      settings = {
        n_lines = 500;
        search_method = "cover_or_next";
      };
    };

    # Surround actions
    # Examples:
    #  - saiw) - [S]urround [A]dd [I]nner [W]ord [)]paren
    #  - sd'   - [S]urround [D]elete [']quote
    #  - sr)'  - [S]urround [R]eplace [)] [']
    mini.surround = {
      enable = true;
      settings = {
        mappings = {
          add = "sa";
          delete = "sd";
          find = "sf";
          find_left = "sF";
          highlight = "sh";
          replace = "sr";
          update_n_lines = "sn";
        };
      };
    };

    # Commenting
    # Examples:
    #  - gcc - Toggle comment on current line
    #  - gc  - Toggle comment on visual selection
    mini.comment = {
      enable = true;
    };

    # Auto pairs
    # Behavior:
    # - Type '(' -> inserts '()' with cursor inside
    # - Type ')' inside '()' -> just moves cursor past ')'
    # - Backspace '(' -> deletes both '()'
    mini.pairs = {
      enable = true;
      settings = {
        modes = { insert = true; command = false; terminal = false; };
        skip_next = [ "" " " "\t" "\r" "\n" "}" "]" ")" ">" ];
        skip_ts = [ "string" ];
        skip_unbalanced = true;
        markdown = true;
      };
    };
  };
}

{
  config,
  pkgs,
  lib,
  ...
}: let
  finter = pkgs.rustPlatform.buildRustPackage rec {
    pname = "finter";
    version = "0.1.15";
    src = pkgs.fetchCrate {
      inherit pname version;
      sha256 = "sha256-YWP5xkAlKZTZuncepG/hj5VwwTRyMKJZaBgICtwA+PU=";
    };
    cargoHash = "sha256-PKZcxApKLOWnYrpISSb53bf+MFIlWgnhogFZr0sv0ZU=";
    meta = with pkgs.lib; {
      description = "A Tmux plugin to quickly create session for folders in configured paths.";
      license = licenses.mit;
      maintainers = with maintainers; ["xixiaofinland"];
    };
  };
  nvimConfigDir = "${config.home.homeDirectory}/dotfiles-nix/dotfiles/nvim_config";
in {
  home.packages = with pkgs; [
    cachix
    eza
    bat
    fd
    fzf
    jq
    nh
    ripgrep
    tree
    gnumake
    nodejs_22
    alacritty
    obsidian

    # custom
    finter

    # nix
    alejandra
    nil

    # lua
    lua-language-server

    # salesforce
    sf

    # aichat doesn't support from external apps
    (pkgs.writeShellScriptBin "aichat" ''
      export OPENAI_API_KEY="$(${pkgs.rbw}/bin/rbw get openai-api-key)"
      exec ${pkgs.aichat}/bin/aichat "$@"
    '')
  ];

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  home.file = {
    ".finter".source = ../dotfiles/.finter;
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".alacritty.toml".source = ../dotfiles/.alacritty.toml;
    ".ignore".source = ../dotfiles/.ignore;
    ".config/direnv/direnv.toml".source = ../dotfiles/direnv/direnv.toml;
    ".tmux_init_actions.sh".source = ../dotfiles/.tmux_init_actions.sh;
    ".config/hypr/hyprland.conf".source = ../dotfiles/hypr/hyprland.conf;
    ".config/hypr/hyprpaper.conf".source = ../dotfiles/hypr/hyprpaper.conf;
    ".config/hypr/random_wall.sh".source = ../dotfiles/hypr/random_wallpaper.sh;
    "Wallpapers" = {
      source = ../dotfiles/Wallpapers;
      recursive = true;
    };
    ".config/waybar/config".source = ../dotfiles/hypr/waybar/config;
    ".config/waybar/style.css".source = ../dotfiles/hypr/waybar/style.css;
  };

  # trade impurity for convenience as I need to update nvim config quite frequently!
  xdg.configFile."nvim" = {
    source =
      config.lib.file.mkOutOfStoreSymlink nvimConfigDir;
    recursive = true;
  };

  # darwin + home manager doesn't automatically link the new files from Nvim config folder.
  home.activation = {
    linkNewNvimFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Linking new Neovim configuration files..."
      find "${nvimConfigDir}" -type f | while read file; do
        relative_path="''${file#${nvimConfigDir}/}"
        target="$HOME/.config/nvim/$relative_path"
        if [ ! -e "$target" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$target")"
          $DRY_RUN_CMD ln -s $VERBOSE_ARG "$file" "$target"
          echo "Linked new file: $relative_path"
        fi
      done
    '';
  };

  # Linux (NixOS) → ~/.config/aichat
  xdg.configFile."aichat" = lib.mkIf pkgs.stdenv.isLinux {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles-nix/dotfiles/aichat";
    recursive = true;
  };

  # macOS → ~/Library/Application Support/aichat
  home.file."Library/Application Support/aichat" = lib.mkIf pkgs.stdenv.isDarwin {
    source =
      config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles-nix/dotfiles/aichat";
    recursive = true;
  };

  programs.rbw = {
    enable = true;
    settings = {
      email = "xi.xiao007@gmail.com";
      lock_timeout = 28800; # 8h
      pinentry =
        if pkgs.stdenv.isDarwin
        then pkgs.pinentry_mac
        else pkgs.pinentry;
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.tmux = {
    enable = true;
    shortcut = "a";
    clock24 = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.catppuccin
      tmuxPlugins.yank
      tmuxPlugins.cpu
    ];
    extraConfig = ''
      # Terminal settings
      set -g default-terminal "tmux-256color"
      set -sa terminal-features ",xterm-256color:RGB"
      set -sa terminal-features ",alacritty:RGB"
      set -ga terminal-features ",xterm-256color:usstyle"
      set -ga terminal-features ",alacritty:usstyle"

      set -g mouse on
      set-option -g detach-on-destroy off

      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      set -g history-limit 10000

      bind x run-shell 'tmux switch-client -n \; kill-session -t "#S"'

      bind u switch-client -l
      bind f display-popup -E "finter"
      bind l split-window -h -c "#{pane_current_path}"
      bind = new-window -c "#{pane_current_path}"
      bind q killp

      # Automatically set window title
      set-option -g allow-rename on
      set-window-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}'

      # default window title colors
      set-window-option -g window-status-style fg=white
      set-window-option -g window-status-style bg=default
      set-window-option -g window-status-style dim

      # active window title colors
      set-window-option -g window-status-current-style fg=white
      set-window-option -g window-status-current-style bg=default
      set-window-option -g window-status-current-style bright

      # BUG: the above defined styles are gone due to the 2 lines below. why?
      set-window-option -g window-status-format '#I_#{b:pane_current_path}'
      set-window-option -g window-status-current-format '#I_#{b:pane_current_path}'

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      set -g @catppuccin_flavour 'mocha'

      # set vi-mode
      set-window-option -g mode-keys vi

      # keybindings
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind -T copy-mode-vi V send -X select-line
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

      # No delay for escape key press
      set -sg escape-time 1

      # Reload tmux config
      bind r source-file ~/.config/tmux/tmux.conf

      # THEME
      set -g status-fg white
      set -g status-bg black
      set -g status-style bright

      set -g status-interval 5
      set -g status-left-length 47
      set -g status-left '#[fg=blue]%H:%M | #[fg=green]%d-%m | #[fg=orange][#S]'
      set -g status-justify centre
      set -g status-right '#[fg=blue]#{cpu_percentage} - #[fg=green]#{ram_percentage}'
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux

      # because the tmux 3.5a bug; this can be removed after sensible script is fixed
      # https://github.com/nix-community/home-manager/issues/5952
      set -gu default-command
      set -g default-shell "$SHELL"
    '';
  };

  programs.fish = {
    enable = true;
    plugins = [
      {
        name = "pure";
        src = pkgs.fishPlugins.pure.src;
      }
    ];
    shellAliases = {
      e = "exit";
      c = "clear";
      n = "nvim";
      # t = "tmux new-session -d -s 0 -n win1 -c ~/dotfiles-nix/; tmux send-keys -t 0:1 'sh $HOME/.tmux_init_actions.sh' Enter; tmux new-window -t 0:2 -n win2 -c ~/dotfiles-nix/; tmux attach -t 0";
      cs = "git --git-dir=$HOME/dotfiles-nix/.git/ --work-tree=$HOME/dotfiles-nix/ status";
      ca = "git --git-dir=$HOME/dotfiles-nix/.git/ --work-tree=$HOME/dotfiles-nix/ add";
      cc = "git --git-dir=$HOME/dotfiles-nix/.git/ --work-tree=$HOME/dotfiles-nix/ commit -am '+'";
      cpp = "git --git-dir=$HOME/dotfiles-nix/.git/ --work-tree=$HOME/dotfiles-nix/ push";
    };

    shellInit = ''
      set -gx PATH $HOME/.local/bin $PATH
    '';

    interactiveShellInit = ''
      set -g fish_greeting ""
      function __fish_command_not_found_handler; end

      # point ssh to rbw-agent
      set -gx SSH_AUTH_SOCK "$XDG_RUNTIME_DIR/rbw/ssh-agent-socket"

      set -g fish_emoji_width 1
      set -g pure_symbol_nix "*" # the original emoji is a double-width Unicode glyph. Fish sometimes miscalculate its display width

      # pure theme
      set -g pure_enable_git true
      set -g pure_show_jobs true
      set -g pure_enable_nixdevshell true

      # custom abbrs
      abbr -a a aichat
      abbr -a l eza -la
      abbr -a la eza -la
      abbr -a ls eza
      abbr -a gs git status
      abbr -a gp git push
      abbr -a gco git checkout
      abbr -a aa "git add .; git commit -am '+'"
      abbr -a app git push
      abbr -a cr cargo r
      abbr -a cb cargo b
      abbr -a js jj st

      abbr -a frepo "find .git/objects/ -type f -empty | xargs rm; git fetch -p; git fsck --full; git pull"
      abbr -a serve "simple-http-server -i -p 9999 ./"

      abbr -a wp-pull "git subtree pull --prefix dotfiles/Wallpapers git@github.com:xixiaofinland/Wallpapers.git main --squash"
      abbr -a wp-push "git subtree push --prefix dotfiles/Wallpapers git@github.com:xixiaofinland/Wallpapers.git main"

      zoxide init fish | source

      COMPLETE=fish jj | source

      # custom functions

      function t
        tmux has-session -t 0 2>/dev/null
        or begin
          tmux new-session -d -s 0 -n win1 -c ~/dotfiles-nix/
          tmux send-keys -t 0:1 'sh $HOME/.tmux_init_actions.sh' Enter
          tmux new-window -t 0:2 -n win2 -c ~/dotfiles-nix/
        end
        tmux select-window -t 0:1
        tmux attach -t 0
      end

      function multicd
          echo cd (string repeat -n (math (string length -- $argv[1]) - 1) ../)
      end
      abbr --add dotdot --regex '^\.\.+$' --function multicd

      # Support both git and jj in prompt branch info section
      # Rename Pure's original function to keep it intact
      functions -c _pure_prompt_git _pure_prompt_git_original

      # Create our wrapper
      function _pure_prompt_git --description 'Print git repository informations: branch name, dirty, upstream ahead/behind'
          if test -d .jj
              # Show parent's description (where you'll squash to)
              set -l parent_desc (jj log -r @- --no-graph -T 'description.first_line()' 2>/dev/null)
              if test -n "$parent_desc"; and test "$parent_desc" != ""
                  set_color brblack
                  echo " @- $parent_desc"
                  set_color normal
              else
                  set_color brblack
                  echo " @-"
                  set_color normal
              end
              return
          end

          if test -n "$VIRTUAL_ENV"
            echo "(venv: (basename $VIRTUAL_ENV)) "
          end

          # Call the original Pure function
          _pure_prompt_git_original $argv
      end;
    '';
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
    ];
  };

  programs.jujutsu = {
    enable = true;
    # ediff = true;
    settings = {
      user = {
        email = "xi.xiao007@gmail.com";
        name = "Xi Xiao";
      };
      ui = {
        paginate = "never";
        editor = "nvim";
        default-command = ["log" "--limit" "5"];
      };
      templates = {
        git_push_bookmark = ''"xx/push-" ++ change_id.short()'';
      };
      aliases = {
        l = ["log" "-r" "(main..@):: | (main..@)-"];
        ll = ["log" "-r" "(master..@):: | (master..@)-"];
        lm = ["log" "-r" "mine()"];
        bto = ["bookmark" "track" "glob:*@origin"];
        pull = [
          "util"
          "exec"
          "--"
          "bash"
          "-c"
          "jj git fetch && jj rebase -s @ -d 'trunk()'"
        ];
      };
    };
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}

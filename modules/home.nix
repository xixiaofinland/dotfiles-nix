{
  config,
  pkgs,
  lib,
  ...
}: let
  finter = pkgs.rustPlatform.buildRustPackage rec {
    pname = "finter";
    version = "0.1.14";
    src = pkgs.fetchCrate {
      inherit pname version;
      sha256 = "sha256-J0EXZTHhGNAQBK1CPX7XmQqhI1t4jfmqlD3n2jrqHP8=";
    };
    cargoHash = "sha256-OIfRxDPX/kFbdlHYkf583k+BqRre1s8IxBBT3stZFLA=";
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
    fd
    fzf
    jq
    nh
    ripgrep
    tree
    zoxide
    pure-prompt

    # git
    jujutsu

    # custom
    finter

    # nix
    alejandra
    nil

    # lua
    lua-language-server
    #luajitPackages.luarocks

    # salesforce
    sf
  ];

  home.file = {
    ".finter".source = ../dotfiles/.finter;
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".alacritty.toml".source = ../dotfiles/.alacritty.toml;
    ".ignore".source = ../dotfiles/.ignore;
    ".config/direnv/direnv.toml".source = ../dotfiles/direnv/direnv.toml;
    ".tmux_init_actions.sh".source = ../dotfiles/.tmux_init_actions.sh;
    # by pass this direnv bug: https://github.com/direnv/direnv/issues/73
    # ".direnvrc".text = ''
    #   export_alias() {
    #     local name=$1
    #     shift
    #     local alias_dir=$PWD/.direnv/aliases
    #     local target="$alias_dir/$name"
    #     mkdir -p "$alias_dir"
    #     PATH_add "$alias_dir"
    #     echo "#!/etc/profiles/per-user/$USER/bin/zsh -e" > "$target"
    #     echo "$@" >> "$target"
    #     chmod +x "$target"
    #   }
    # '';
    # ".config/nvim" = {
    #   source = ../../dotfiles/nvim;
    #   recursive = true;
    # };
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

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  # programs.cachix = {
  #   enable = true;
  #   caches = [ "xixiaofinland" "cachix" "nixpkgs" ];
  # };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
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
      set-option -sa terminal-overrides ",xterm*:Tc"
      set -g mouse on
      set-option -g detach-on-destroy off

      unbind C-b
      set -g prefix C-a
      bind C-a send-prefix

      set -g history-limit 10000

      bind-key x run-shell 'tmux switch-client -n \; kill-session -t "#S"'

      bind C-u switch-client -l
      bind C-o display-popup -E "finter"

      bind J resize-pane -D 10
      bind K resize-pane -U 10
      bind H resize-pane -L 10
      bind L resize-pane -R 10

      bind M-j resize-pane -D
      bind M-k resize-pane -U
      bind M-h resize-pane -L
      bind M-l resize-pane -R

      # Automatically set window title
      set-option -g allow-rename on
      set-window-option -g automatic-rename on
      set-option -g automatic-rename-format '#{b:pane_current_path}'

      # Start windows and panes at 1, not 0
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      set -g @catppuccin_flavour 'mocha'

      # set vi-mode
      set-window-option -g mode-keys vi

      # keybindings
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

      bind \' split-window -h -c "#{pane_current_path}"
      bind \\ split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind = split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
      bind q killp

      # No delay for escape key press
      set -sg escape-time 0

      # Reload tmux config
      bind r source-file ~/.tmux.conf

      # THEME
      set -g status-fg white
      set -g status-bg black
      set -g status-style bright

      # default window title colors
      set-window-option -g window-status-style fg=white
      set-window-option -g window-status-style bg=default
      set-window-option -g window-status-style dim

      # active window title colors
      set-window-option -g window-status-current-style fg=white
      set-window-option -g window-status-current-style bg=default
      set-window-option -g window-status-current-style bright

      set -g status-interval 5
      set -g status-left-length 47
      set -g status-left '#[fg=blue]%H:%M | #[fg=green]%d-%m | #[fg=orange][#S]'
      set -g status-justify centre
      set -g status-right '#[fg=blue]#{cpu_percentage} - #[fg=green]#{ram_percentage}'
      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux
    '';
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "";
      plugins = [
        "git"
        "nvm"
        "npm"
        "fzf"
        "z"
      ];
    };
    initExtra = ''
      autoload -U promptinit; promptinit
      prompt pure
    '';
    shellAliases = {
      gs = "git status";
      e = "exit";
      c = "clear";
      n = "nvim";
      ls = "eza";
      t = "tmux new-session -d -s 0 -n win -c ~/dotfiles-nix/; tmux send-keys -t 0:win 'sh $HOME/.tmux_init_actions.sh' Enter; tmux attach -t 0:win";
      cs = "git --git-dir=$HOME/dotfiles-nix/.git/ --work-tree=$HOME/dotfiles-nix/ status";
      ca = "git --git-dir=$HOME/dotfiles-nix/.git/ --work-tree=$HOME/dotfiles-nix/ add";
      cc = "git --git-dir=$HOME/dotfiles-nix/.git/ --work-tree=$HOME/dotfiles-nix/ commit -am '+'";
      cpp = "git --git-dir=$HOME/dotfiles-nix/.git/ --work-tree=$HOME/dotfiles-nix/ push";
      frepo = "find .git/objects/ -type f -empty | xargs rm; git fetch -p; git fsck --full; git pull";
      fzsh = "cd ~; mv .zsh_history .zsh_history_bad; strings .zsh_history_bad > .zsh_history; fc -R .zsh_history";

      dr="RUST_LOG=debug cargo r";
      tr="RUST_BACKTRACE=1 cargo r";
      rr="cargo r";
      tt="cargo test --test test --  --show-output";
      tp="cargo test prettier --  --show-output";
      tm="cargo test manual --  --show-output";
      te="cargo test extra --  --show-output";
      dtp="RUST_BACKTRACE=1 cargo test prettier --  --show-output";
      aa="git add .; git commit -am '+'";
      app="git push";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = with pkgs; [
    ];
  };

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
  # nix.settings.trusted-users = ["nixos" "xixiao"];
}

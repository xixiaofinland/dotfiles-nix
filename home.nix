{ config, pkgs, ... }:

{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  # home.username = user;
  # home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
   
    libgcc
    nixpkgs-fmt
    fzf
    ripgrep
    zoxide
    fd
    tree
  ];

  home.file = {
    ".gitconfig".source = ./dotfiles/.gitconfig;
    ".alacritty.toml".source = ./dotfiles/.alacritty.toml;
    ".ignore".source = ./dotfiles/.ignore;
    ".tmux.conf".source = ./dotfiles/.tmux.conf;
    ".config/nvim" = {
      source = ./dotfiles/nvim;
      recursive = true;
    };
  };

  # xdg.configFile."nvim" = {
  #   source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles-nix/dotfiles/nvim";
  #   recursive = true;
  # };

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  programs.tmux ={
    enable = true;
    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.vim-tmux-navigator
      tmuxPlugins.catppuccin
      tmuxPlugins.yank
      tmuxPlugins.cpu
    ];
  };

  programs.zsh = {
    enable = true;
    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
	   "git"
           "nvm"
           "npm"
           "fzf"
           "z"
      ];
    };
    shellAliases = {
      gs="git status";
      e="exit";
      c="clear";
      n="nvim";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  programs.git = {
    enable = true;
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}

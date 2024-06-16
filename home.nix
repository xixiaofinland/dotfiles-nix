{ config, pkgs, ... }:

{
  home.username = "nixos";
  home.homeDirectory = "/home/nixos";
  # home.username = user;
  # home.homeDirectory = "/home/${user}";

  home.packages = with pkgs; [
    clang
    libgcc
    cowsay
    nixpkgs-fmt
    fzf
    ripgrep
    zoxide
    fd
  ];

  home.file = {
    #".zshrc".source = ./.zshrc;
    ".gitconfig".source = ./.gitconfig;
    ".alacritty.toml".source = ./.alacritty.toml;
    ".ignore".source = ./.ignore;
    ".tmux.conf".source = ./.tmux.conf;
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };


  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  programs.tmux = {
    enable = true;
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
  };

  programs.neovim = {
    enable = true;
  };

  programs.git = {
    enable = true;
  };

  home.stateVersion = "23.11";
  programs.home-manager.enable = true;
}

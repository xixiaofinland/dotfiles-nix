{ pkgs, ... }: {
  home.username = "finxxi";
  home.homeDirectory = "/home/finxxi";
  home.stateVersion = "24.05";
  home.packages = [
    pkgs.cowsay
    pkgs.nixpkgs-fmt
  ];
  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };
  home.file = {
    ".zshrc".source = ./.zshrc;
    ".gitconfig".source = ./.gitconfig;
    ".alacritty.toml".source = ./.alacritty.toml;
    ".ignore".source = ./.ignore;
    ".tmux.conf".source = ./.tmux.conf;
    ".config/nvim" = {
      source = ./nvim;
      recursive = true;
    };
  };
  programs.home-manager.enable = true;
}

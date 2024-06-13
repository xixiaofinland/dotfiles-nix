{ pkgs, ... }: {
  home.username = "finxxi";
  home.homeDirectory = "/home/finxxi";
  home.stateVersion = "24.05";
  home.packages = [
    pkgs.cowsay
    pkgs.nixpkgs-fmt
  ];
  home.file = {
    ".zshrc".source = ./.zshrc;
    ".gitconfig".source = ./.gitconfig;
    ".alacritty.toml".source = ./.alacritty.toml;
    ".ignore".source = ./.ignore;
    ".tmux.conf".source = ./.tmux.conf;
  };
  programs.home-manager.enable = true;
}

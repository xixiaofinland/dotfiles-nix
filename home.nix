{ pkgs, ... }: {
  home.username = "finxxi";
  home.homeDirectory = "/home/finxxi";
  home.stateVersion = "24.05";
  home.packages = [
    pkgs.cowsay
    pkgs.nixpkgs-fmt
  ];
  programs.home-manager.enable = true;
}

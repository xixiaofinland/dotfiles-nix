{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./home.nix
    ./home-hyprland.nix
  ];
}

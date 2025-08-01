{
  config,
  lib,
  pkgs,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  environment.systemPackages = with pkgs; [
    gcc
    wget
    git
    curl
    usbutils
  ];

  # environment.shells = with pkgs; [fish];
  programs.fish.enable = true;
}

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
  ];

  programs.fish.enable = true;
  environment.shells = with pkgs; [fish];
}

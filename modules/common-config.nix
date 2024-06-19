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

  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;

  nix.settings.auto-optimise-store = true;
}

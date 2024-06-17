{
  config,
  lib,
  pkgs,
  ...
}: {
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # zsh as default shell
  environment.shells = with pkgs; [zsh];
  programs.zsh.enable = true;

  nix.settings.auto-optimise-store = true;
}

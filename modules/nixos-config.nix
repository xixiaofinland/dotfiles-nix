{
  config,
  lib,
  pkgs,
  ...
}: {
  security.sudo.enable = true;

  users.defaultUserShell = pkgs.fish;

  time.timeZone = "Europe/Helsinki";

  system.stateVersion = "24.05";

  system.nixos.label = "|";
  boot.loader.systemd-boot.configurationLimit = 5;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;
}

{
  config,
  lib,
  pkgs,
  ...
}: {
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  security.sudo.enable = true;

  users.defaultUserShell = pkgs.fish;

  time.timeZone = "Europe/Helsinki";

  system.stateVersion = "24.05";

  boot.loader.systemd-boot.configurationLimit = 10;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;
}

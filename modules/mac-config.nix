{
  config,
  lib,
  pkgs,
  ...
}: {
  services.nix-daemon.enable = true;
  system.stateVersion = 4;

  nixpkgs.hostPlatform = "x86_64-darwin";

  nix.gc = {
    automatic = true;
    interval = {
      Weekday = 0;
      Hour = 0;
      Minute = 0;
    };
    options = "--delete-older-than 14d";
  };

  # bug: https://github.com/NixOS/nix/issues/7273
  nix.settings.auto-optimise-store = false;
}

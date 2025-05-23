{
  config,
  lib,
  pkgs,
  ...
}: {
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
  users.users.xixiao = {
    name = "xixiao";
    home = "/Users/xixiao";
    shell = pkgs.fish;
  };

  # Ensure fish is available
  environment.systemPackages = [pkgs.fish];
}

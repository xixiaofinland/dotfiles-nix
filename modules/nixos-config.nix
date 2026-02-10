{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.nix-ld.enable = true; # in order for some npm installed tools to work

  security.sudo.enable = true;
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=30
  '';

  users.defaultUserShell = pkgs.fish;

  time.timeZone = "Europe/Helsinki";
  services.timesyncd.enable = true;

  system.stateVersion = "24.05";

  system.nixos.label = "-";
  boot.loader.systemd-boot.configurationLimit = 5;
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.settings.auto-optimise-store = true;
}

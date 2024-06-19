{
  config,
  lib,
  pkgs,
  ...
}: {
  wsl.enable = true;
  wsl.defaultUser = "nixos";

  boot.loader.systemd-boot.configurationLimit = 10;
  system.stateVersion = "24.05";
}

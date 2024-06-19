{
  config,
  lib,
  pkgs,
  ...
}: {
  services.nix-daemon.enable = true;
  system.stateVersion = 4;
  nixpkgs.hostPlatform = "x86_64-darwin";
}

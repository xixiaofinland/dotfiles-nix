{
  ...
}: {
  imports = [
    ./home-core.nix
    ./home-files.nix
    ./home-nvim-linking.nix
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}

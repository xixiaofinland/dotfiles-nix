{
  description = "My Home Manager Configuration with Dotfiles";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      homeConfigurations = {
        "finxxi" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          modules = [ ./home.nix ]; # Defined later
        };
      };
    };
}


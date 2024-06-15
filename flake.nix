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
        # pkgs = import nixpkgs { inherit system; };
        # user = builtins.getEnv "USER";
      in
      {
      # homeConfigurations = {
      #       "your.username" = home-manager.lib.homeManagerConfiguration {
      #           # Note: I am sure this could be done better with flake-utils or something
      #           pkgs = import nixpkgs { system = "x86_64-darwin"; };
      #
      #           modules = [ ./home.nix ]; # Defined later
      #       };
      #   };

        homeConfigurations = {
            "finxxi" = home-manager.lib.homeManagerConfiguration {
                # Note: I am sure this could be done better with flake-utils or something
                pkgs = import nixpkgs { system = "x86_64-linux"; };

                modules = [ ./home.nix ]; # Defined later
            };
        };
      };
}


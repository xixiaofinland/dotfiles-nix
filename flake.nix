{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    nixos-wsl,
    nix-darwin,
    nix-homebrew,
    homebrew-bundle,
    homebrew-core,
    homebrew-cask,
  } @ inputs: let
    nixos-user = "nixos";
    nixos-hostname = "nixos";
    nixos-sys = "x86_64-linux";

    mac-user = "xixiao";
    mac-hostname = "Xis-MacBook-Pro";
    mac-sys = "x86_64-darwin";
  in {
    nixosConfigurations = {
      "${nixos-hostname}" = nixpkgs.lib.nixosSystem {
        system = "${nixos-sys}";
        modules = [
          ./modules/common-config.nix
          ./modules/nixos/config.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${nixos-user}" = import ./home.nix;
          }
        ];
      };
    };

    darwinConfigurations = {
      "${mac-hostname}" = nix-darwin.lib.darwinSystem {
        system = "${mac-sys}";
        modules = [
          ./modules/common-config.nix
          ./modules/mac/config.nix
          home-manager.darwinModules.home-manager
          # nix-homebrew.darwinModules.nix-homebrew
          # {
          #   nix-homebrew = {
          #     user = "${mac-user}";
          #     enable = true;
          #     taps = {
          #       "homebrew/homebrew-core" = homebrew-core;
          #       "homebrew/homebrew-cask" = homebrew-cask;
          #       "homebrew/homebrew-bundle" = homebrew-bundle;
          #     };
          #     mutableTaps = false;
          #     autoMigrate = true;
          #   };
          # }
        ];
      };
    };

    formatter.${mac-sys} = nixpkgs.legacyPackages.${mac-sys}.alejandra;
    formatter.${nixos-sys} = nixpkgs.legacyPackages.${nixos-sys}.alejandra;
  };
}

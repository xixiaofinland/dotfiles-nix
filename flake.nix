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

    linuxSystems = ["x86_64-linux" "aarch64-linux"];
    darwinSystems = ["aarch64-darwin" "x86_64-darwin"];
    forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
  in {
    # nixosConfigurations = {
    #   "${nixos-hostname}" = nixpkgs.lib.nixosSystem {
    #     system = "${nixos-sys}";
    #     modules = [
    #       ./modules/common-config.nix
    #       ./modules/nixos/config.nix
    #       nixos-wsl.nixosModules.wsl
    #       home-manager.nixosModules.home-manager
    #       {
    #         home-manager.useGlobalPkgs = true;
    #         home-manager.useUserPackages = true;
    #         home-manager.users."${nixos-user}" = import ./home.nix;
    #       }
    #     ];
    #   };
    # };

    nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system: let
      user = "nixos";
    in
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          ./modules/common-config.nix
          ./modules/nixos/config.nix
          nixos-wsl.nixosModules.wsl
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./home.nix;
            };
          }
        ];
      });

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

    # darwinConfigurations = nixpkgs.lib.genAttrs darwinSystems (
    #   system: let
    #     user = "xixiao";
    #   in
    #     nix-darwin.lib.darwinSystem {
    #       inherit system;
    #       specialArgs = inputs;
    #       modules = [
    #         home-manager.darwinModules.home-manager
    #         nix-homebrew.darwinModules.nix-homebrew
    #         {
    #           nix-homebrew = {
    #             inherit user;
    #             enable = true;
    #             taps = {
    #               "homebrew/homebrew-core" = homebrew-core;
    #               "homebrew/homebrew-cask" = homebrew-cask;
    #               "homebrew/homebrew-bundle" = homebrew-bundle;
    #             };
    #             mutableTaps = false;
    #             autoMigrate = true;
    #           };
    #         }
    #         # ./hosts/darwin
    #       ];
    #     }
    # );

    # nix code formatter
    # formatter = forAllSystems (system: {
    #   ${system} = nixpkgs.legacyPackages.${system}.alejandra;
    # });

    # devShells = forAllSystems devShell;

    # forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;

    #   devShell = system: let pkgs = nixpkgs.legacyPackages.${system}; in {
    #     default = with pkgs; mkShell {
    #       nativeBuildInputs = with pkgs; [ bashInteractive git ];
    #       shellHook = with pkgs; ''
    #         export EDITOR=vim
    #       '';
    #     };
    #   };

    formatter.${mac-sys} = nixpkgs.legacyPackages.${mac-sys}.alejandra;
    formatter.${nixos-sys} = nixpkgs.legacyPackages.${nixos-sys}.alejandra;
  };
}

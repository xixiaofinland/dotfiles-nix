{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl.url = "github:nix-community/nixos-wsl";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    nixos-wsl,
    nix-darwin,
  } @ inputs: let
    nixos-uname = "nixos";
    nixos-hostname = "nixos";
    nixos-sys = "x86_64-linux";

    mac-uname = "xixiao";
    mac-hostname = "Xis-MacBook-Pro";
    mac-sys = "x86_64-darwin";

    specialArgs =
      inputs
      // {
        inherit nixos-uname nixos-sys mac-uname mac-sys;
      };
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
            home-manager.users."${nixos-uname}" = import ./home.nix;
          }
        ];
      };
    };

    darwinConfigurations = {
      "${mac-hostname}" = nix-darwin.lib.darwinSystem {
        inherit specialArgs;
        system = "${mac-sys}";
        modules = [
          ./modules/common-config.nix
          ./modules/mac/config.nix
        ];
      };
    };

    # nix code formatter
    formatter.${mac-sys} = nixpkgs.legacyPackages.${mac-sys}.alejandra;
    formatter.${nixos-sys} = nixpkgs.legacyPackages.${nixos-sys}.alejandra;
  };
}

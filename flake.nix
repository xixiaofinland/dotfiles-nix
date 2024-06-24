{
  description = "A simple NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sfdx-nix = {
      url = "github:rfaulhaber/sfdx-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    # nix-homebrew = {
    #   url = "github:zhaofengli-wip/nix-homebrew";
    #   inputs.nix-darwin.follows = "nix-darwin";
    # };
    # homebrew-bundle = {
    #   url = "github:homebrew/homebrew-bundle";
    #   flake = false;
    # };
    # homebrew-core = {
    #   url = "github:homebrew/homebrew-core";
    #   flake = false;
    # };
    # homebrew-cask = {
    #   url = "github:homebrew/homebrew-cask";
    #   flake = false;
    # };
  };

  outputs = {
    self,
    flake-utils,
    home-manager,
    nixpkgs,
    nixos-wsl,
    nix-darwin,
    rust-overlay,
    sfdx-nix,
    # nix-homebrew,
    # homebrew-bundle,
    # homebrew-core,
    # homebrew-cask,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      nixos-user = "nixos";
      nixos-hostname = "nixos";
      mac-user = "xixiao";
      mac-hostname = "Xis-MacBook-Pro";
      overlays = [
        rust-overlay.overlays.default
        (final: prev: {
          rustToolchain = final.rust-bin.stable.latest.default.override {extensions = ["rust-src"];};
        })
      ];
      pkgs = import nixpkgs {
        inherit system overlays;
        sf = sfdx-nix.packages.${system}.sf;
      };
    in {
      nixosConfigurations = {
        "${nixos-hostname}" = pkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules/common-config.nix
            ./modules/nixos-config.nix
            nixos-wsl.nixosModules.wsl
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${nixos-user}" = import ./modules/home.nix;
            }
          ];
        };
      };

      darwinConfigurations = {
        "${mac-hostname}" = nix-darwin.lib.darwinSystem {
          inherit system;
          modules = [
            ./modules/common-config.nix
            ./modules/mac-config.nix
            {
              users.users.${mac-user}.home = "/Users/${mac-user}";
            }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users."${mac-user}" = import ./modules/home.nix;
            }
          ];
        };
      };

      devShells = rec {
        default = rust;
        rust = pkgs.mkShell {
          packages = with pkgs; [
            rustToolchain
          ];
          env = {
            RUST_SRC_PATH = "${pkgs.rustToolchain}/lib/rustlib/src/rust/library";
          };
          shellHook = ''
            echo "🦀🦀🦀🦀 hello Rust!"
          '';
        };

        sf = pkgs.mkShell {
          packages = with pkgs; [
            sf
            pmd
          ];

          shellHook = ''
            echo "☁️ ☁️ ☁️ ☁️  hello Salesforce!"
          '';
        };

        lua = pkgs.mkShell {
          packages = with pkgs; [
            lua-language-server
          ];
          shellHook = ''
            echo "🔮🔮🔮🔮 hello Lua!"
          '';
        };

        nix = pkgs.mkShell {
          packages = with pkgs; [
            nil
            statix
            vulnix
          ];
          shellHook = ''
            echo "💠💠💠💠 hello Nix!"
          '';
        };
      };

      # formatter.${mac-sys} = nixpkgs.legacyPackages.${mac-sys}.alejandra;
      # formatter.${nixos-sys} = nixpkgs.legacyPackages.${nixos-sys}.alejandra;
    });
}

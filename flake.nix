{
  description = "A simple NixOS flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
      url = "github:xixiaofinland/sfdx-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
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
  }: let
    nixos-user = "nixos";
    nixos-hostname = "nixos";
    nixos-sys = "x86_64-linux";
    mac-user = "xixiao";
    mac-hostname = "Xis-MacBook-Pro";
    mac-sys = "x86_64-darwin";
    overlays = [
      rust-overlay.overlays.default
      (
        final: prev: {
          sf = sfdx-nix.packages.${final.system}.sf;
          rustToolchainStable = final.rust-bin.stable.latest.default;
          rustToolchainNightly = final.rust-bin.nightly.latest.default;
          rustToolchain0625 = final.rust-bin.nightly."2024-06-25".default;
        }
      )
    ];
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "${nixos-sys}"
        "${mac-sys}"
      ] (system:
        function (import nixpkgs {
          inherit system overlays sfdx-nix;
        }));
  in {
    nixosConfigurations = {
      "${nixos-hostname}" = nixpkgs.lib.nixosSystem rec {
        system = "${nixos-sys}";
        pkgs = import nixpkgs {
          inherit system overlays sfdx-nix;
        };
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
          {
            nix.settings = {
              substituters = [
                "https://xixiaofinland.cachix.org"
                "https://cachix.cachix.org"
                "https://nixpkgs.cachix.org"
              ];
              trusted-public-keys = [
                "xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKayc="
                "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
                "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
              ];
              trusted-users = ["nixos"];
            };
          }
        ];
      };
    };

    darwinConfigurations = {
      "${mac-hostname}" = nix-darwin.lib.darwinSystem rec {
        system = "${mac-sys}";
        pkgs = import nixpkgs {
          inherit system overlays sfdx-nix;
        };
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
          {
            nix = {
              settings = {
                trusted-substituters = [
                  "https://xixiaofinland.cachix.org"
                  "https://cachix.cachix.org"
                  "https://nixpkgs.cachix.org"
                ];
                trusted-public-keys = [
                  "xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKayc="
                  "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
                  "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
                ];
                trusted-users = ["root" "xixiao"];
              };
              # extraOptions = ''
              #   trusted-users = ["root" "nixos" "xixiao"];
              # '';
            };
          }
        ];
      };
    };

    devShells = forAllSystems (pkgs: rec {
      default = rust;

      rust = let
        packages = with pkgs; [
          rust-bin.stable.latest.default
          rust-analyzer
        ];
      in
        pkgs.mkShell {
          name = "Rust";
          packages = packages;
          shellHook = ''
            echo "🦀🦀🦀🦀 hello Rust Stable!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };

      afmt = let
        packages = with pkgs; [
          # rust-bin.stable.latest.default
          (rust-bin.stable.latest.default.override {
            extensions = ["rust-src"];
            targets = ["wasm32-unknown-unknown"];
          })
          rust-analyzer
          nodejs_22
          jdk
          parallel
          gnuplot
          mdbook
          wasm-bindgen-cli
          wasm-pack
        ];
      in
        pkgs.mkShell {
          name = "Afmt";
          packages = packages;
          shellHook = ''
            echo "🚀🚀🚀🚀 Hello Afmt!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };

      rust-nightly = let
        packages = with pkgs; [
          rust-bin.nightly.latest.default
          rust-analyzer
        ];
      in
        pkgs.mkShell {
          name = "Rust-nightly";
          packages = packages;
          shellHook = ''
            echo "🦀🦀🦀🦀 hello Rust Nightly!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };

      sf = let
        packages = with pkgs; [
          jdk
          nodejs_22
          pmd
          universal-ctags
        ];
      in
        pkgs.mkShell {
          name = "Sf";
          packages = packages;
          shellHook = ''
            echo "☁️ ☁️ ☁️ ☁️  hello Salesforce!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };

      tree = let
        packages = with pkgs; [
          tree-sitter
          nodejs_22
          prettierd
        ];
      in
        pkgs.mkShell {
          name = "tree-sitter";
          packages = packages;
          shellHook = ''
            echo "🌳🌳🌳🌳 hello Tree-sitter!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };

      nvim = let
        packages = with pkgs; [
          gnumake
        ];
      in
        pkgs.mkShell {
          name = "Nvim";
          packages = packages;
          shellHook = ''
            echo "🅽 🅽 🅽 🅽  hello Nvim!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };

      # haskell = let
      #   packages = with pkgs; [
      #     # stack
      #     ghc
      #   ];
      # in
      #   pkgs.mkShell {
      #     name = "Haskell";
      #     packages = packages;
      #     shellHook = ''
      #       echo "📘📘📘📘 hello Haskell!"
      #       echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
      #     '';
      #   };
    });

    # formatter.${mac-sys} = nixpkgs.legacyPackages.${mac-sys}.alejandra;
    # formatter.${nixos-sys} = nixpkgs.legacyPackages.${nixos-sys}.alejandra;
  };
}

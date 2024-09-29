{
  description = "A simple NixOS flake";

  nixConfig = {
    trusted-substituters = [
      "https://xixiaofinland.cachix.org"
      "https://cachix.cachix.org"
      "https://nixpkgs.cachix.org"
    ];
    trusted-public-keys = [
      "xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKayc="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trusted-users = ["root" "nixos" "xixiao"];
  };

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
  }: let
    nixos-user = "nixos";
    nixos-hostname = "nixos";
    nixos-sys = "x86_64-linux";
    mac-user = "xixiao";
    mac-hostname = "Xis-MacBook-Pro";
    mac-sys = "x86_64-darwin";
    overlays = [
      rust-overlay.overlays.default
      (final: prev: {
        sf = sfdx-nix.packages.${final.system}.sf;
        rustToolchainStable = final.rust-bin.stable.latest.default.override {
          extensions = ["rust-src"];
        };
        rustToolchainNightly = final.rust-bin.nightly.latest.default.override {
          extensions = ["rust-src"];
        };
        rustToolchain0625 = final.rust-bin.nightly."2024-06-25".default.override {
          extensions = ["rust-src" "rustc-dev"];
        };
      })
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
              };
              extraOptions = ''
                trusted-users = root xixiao;
                trusted-users = ["root" "nixos" "xixiao"];
              '';
            };
          }
        ];
      };
    };

    devShells = forAllSystems (pkgs: rec {
      default = rust;

      rust = let
        packages = with pkgs; [
          (rust-bin.stable.latest.default.override {
            extensions = ["rust-src"];
          })
          rust-analyzer
        ];
      in
        pkgs.mkShell {
          name = "Rust";
          packages = packages;
          env = {
            RUST_SRC_PATH = "${pkgs.rust-bin.stable.latest.default}/lib/rustlib/src/rust/library";
          };
          shellHook = ''
            echo "🦀🦀🦀🦀 hello Rust Stable!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };

      afmt = let
        packages = with pkgs; [
          (rust-bin.stable.latest.default.override {
            extensions = ["rust-src"];
          })
          rust-analyzer
          nodejs_22
          jdk
        ];
      in
        pkgs.mkShell {
          name = "Afmt";
          packages = packages;
          env = {
            RUST_SRC_PATH = "${pkgs.rust-bin.stable.latest.default}/lib/rustlib/src/rust/library";
          };
          shellHook = ''
            echo "🚀🚀🚀🚀 Hello Afmt!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"

            export_alias dr "RUST_LOG=debug cargo r"
            export_alias rr "cargo r"
            export_alias tt "cargo t"
            export_alias tp "cargo t prettier"
            export_alias tpp "cargo t extra"
            export_alias tm "cargo t manual"
            export_alias aa "git add .; git commit -am '+'"
            export_alias app "git push"
            export_alias ap "git push"
          '';
        };

      rust-nightly = let
        packages = with pkgs; [
          (rust-bin.nightly.latest.default.override {
            extensions = ["rust-src"];
          })
          rust-analyzer
        ];
      in
        pkgs.mkShell {
          name = "Rust-nightly";
          packages = packages;
          env = {
            RUST_SRC_PATH = "${pkgs.rust-bin.nightly.latest.default}/lib/rustlib/src/rust/library";
          };
          shellHook = ''
            echo "🦀🦀🦀🦀 hello Rust Nightly!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };

      rust-fmt = let
        packages = with pkgs; [
          (rust-bin.nightly."2024-08-17".default.override {
            extensions = ["rust-src" "rustc-dev"];
          })
          rust-analyzer
        ];
      in
        pkgs.mkShell {
          name = "Rust-Fmt";
          packages = packages;
          env = {
            RUST_SRC_PATH = "${pkgs.rust-bin.nightly."2024-06-25".default}/lib/rustlib/src/rust/library";
          };
          shellHook = ''
            echo "🦀🦀🦀🦀 hello Rust Nightly (0625)!"
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

      haskell = let
        packages = with pkgs; [
          # stack
          ghc
        ];
      in
        pkgs.mkShell {
          name = "Haskell";
          packages = packages;
          shellHook = ''
            echo "📘📘📘📘 hello Haskell!"
            echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
          '';
        };
    });

    # formatter.${mac-sys} = nixpkgs.legacyPackages.${mac-sys}.alejandra;
    # formatter.${nixos-sys} = nixpkgs.legacyPackages.${nixos-sys}.alejandra;
  };
}

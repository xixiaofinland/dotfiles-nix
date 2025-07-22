{
  description = "A simple NixOS flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/nixos-wsl";
      # inputs.flake-utils.follows = "flake-utils";
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
    nixos-wsl-user = "nixos";
    nixos-wsl-hostname = "nixos";
    hyperland-pc-user = "finxxi";
    hyperland-pc-hostname = "hyperland-pc";
    nixos-sys = "x86_64-linux";
    mac-user = "xixiao";
    mac-hostname = "Xis-MacBook-Pro";
    mac-sys = "x86_64-darwin";
    lib = nixpkgs.lib;
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
    nixos-baseModules = userName: [
      ./modules/common-config.nix
      ./modules/nixos-config.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."${userName}" = import ./modules/home.nix;
      }
      {
        nix.settings = {
          substituters = [
            "https://xixiaofinland.cachix.org"
            "https://cachix.cachix.org"
            "https://nixpkgs.cachix.org"
          ];
          trusted-public-keys = [
            "xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKaych"
            "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
            "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
          ];
          trusted-users = [userName];
        };
      }
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
      "${nixos-wsl-hostname}" = nixpkgs.lib.nixosSystem rec {
        system = "${nixos-sys}";
        pkgs = import nixpkgs {
          inherit system overlays sfdx-nix;
          config.allowUnfreePredicate = pkg:
            builtins.elem (lib.getName pkg) ["obsidian"];
        };
        modules =
          nixos-baseModules nixos-wsl-user
          ++ [
            nixos-wsl.nixosModules.wsl
            {
              wsl.enable = true;
              wsl.defaultUser = "nixos";
            }
          ];
      };

      "${hyperland-pc-hostname}" = nixpkgs.lib.nixosSystem rec {
        system = "${nixos-sys}";
        pkgs = import nixpkgs {
          inherit system overlays sfdx-nix;
          config.allowUnfreePredicate = pkg:
            builtins.elem (lib.getName pkg) ["obsidian"];
        };
        specialArgs = {
          user = hyperland-pc-user;
          hostName = hyperland-pc-hostname;
        };
        modules =
          nixos-baseModules hyperland-pc-user ++ [./modules/hyperland-config.nix];
      };
    };

    darwinConfigurations = {
      "${mac-hostname}" = nix-darwin.lib.darwinSystem rec {
        system = "${mac-sys}";
        pkgs = import nixpkgs {
          inherit system overlays sfdx-nix;
          config.allowUnfreePredicate = pkg:
            builtins.elem (lib.getName pkg) ["obsidian"];
        };
        modules = [
          ./modules/common-config.nix
          ./modules/mac-config.nix
          {
            users.users.${mac-user} = {
              shell = pkgs.fish;
              home = "/Users/${mac-user}";
            };
          }
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users."${mac-user}" = import ./modules/home.nix;
          }
          {
            nix = {
              package = pkgs.nixStable; # pull in the nix binary from cache, NixOS doesn't need to do so
              extraOptions = ''
                experimental-features = nix-command flakes
              '';
              settings = {
                trusted-substituters = [
                  "https://xixiaofinland.cachix.org"
                  "https://cachix.cachix.org"
                  "https://nixpkgs.cachix.org"
                  "https://cache.nixos.org"
                ];
                trusted-public-keys = [
                  "xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKayc="
                  "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
                  "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                ];
                trusted-users = ["root" "xixiao"];
              };
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
          cargo-audit
          cargo-deny
          cargo-tarpaulin
          rust-analyzer
          jdk
          parallel
          wasm-bindgen-cli
          wasm-pack
          simple-http-server
          prettierd
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

      blog = let
        packages = with pkgs; [
          rust-bin.stable.latest.default
          rust-analyzer
          mdbook
        ];
      in
        pkgs.mkShell {
          name = "Blog";
          packages = packages;
          shellHook = ''
            echo "📝📝📝📝 hello Blog!"
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
          prettierd
          emscripten
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
          # gnumake
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

      python = let
        packages = with pkgs; [
          (python311.withPackages (ps:
            with ps; [
              pip
              ipython
              ruff
            ]))
          cmake
          gcc
        ];
      in
        pkgs.mkShell {
          name = "Python";
          packages = packages;
          shellHook = ''
            echo "🧠🤖🧠🤖 hello Python development!"
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
  };
}

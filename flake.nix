{
  description = "A simple NixOS flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
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
    nix-darwin,
    rust-overlay,
    sfdx-nix,
  }: let
    hyprland-pc-user = "finxxi";
    hyprland-pc-hostname = "hyprland-pc";
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
        }
      )
    ];
    nixos-baseModules = userName: homeModule: [
      ./modules/common-config.nix
      ./modules/nixos-config.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users."${userName}" = import homeModule;
      }
      {
        nix.settings = {
          substituters = [
            "https://cache.nixos.org" # Official cache first
            "https://nix-community.cachix.org" # Community cache second
            "https://xixiaofinland.cachix.org" # Your personal cache
            "https://cachix.cachix.org" # Generic cachix
            "https://nixpkgs.cachix.org" # Last resort
          ];
          trusted-public-keys = [
            "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
            "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
            "xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKayc="
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
      "${hyprland-pc-hostname}" = nixpkgs.lib.nixosSystem rec {
        system = "${nixos-sys}";
        pkgs = import nixpkgs {
          inherit system overlays sfdx-nix;
          config = {
            # Fixme: Nvida install still gives error
            # allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["obsidian" "nvidia-x11"];
            allowUnfree = true;
          };
        };
        specialArgs = {
          user = hyprland-pc-user;
          hostName = hyprland-pc-hostname;
        };
        modules =
          nixos-baseModules hyprland-pc-user ./modules/home-combined.nix ++ [./modules/hyprland-config.nix];
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
                  "https://cache.nixos.org" # Official cache first
                  "https://nix-community.cachix.org" # Community cache second
                  "https://xixiaofinland.cachix.org" # Your personal cache
                  "https://cachix.cachix.org" # Generic cachix
                  "https://nixpkgs.cachix.org" # Last resort
                ];
                trusted-public-keys = [
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                  "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
                  "xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKayc="
                  "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
                  "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
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

          cargo-tarpaulin
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

      # afmt = let
      #   packages = with pkgs; [
      #     # rust-bin.stable.latest.default
      #     (rust-bin.stable.latest.default.override {
      #       extensions = ["rust-src"];
      #       targets = ["wasm32-unknown-unknown"];
      #     })
      #     cargo-audit
      #     cargo-deny
      #     cargo-tarpaulin
      #     rust-analyzer
      #     jdk
      #     parallel
      #     wasm-bindgen-cli
      #     wasm-pack
      #     simple-http-server
      #     prettierd
      #   ];
      # in
      #   pkgs.mkShell {
      #     name = "Afmt";
      #     packages = packages;
      #     shellHook = ''
      #       echo "🚀🚀🚀🚀 Hello Afmt!"
      #       echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
      #     '';
      #   };

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

      # rust-nightly = let
      #   packages = with pkgs; [
      #     rust-bin.nightly.latest.default
      #     rust-analyzer
      #   ];
      # in
      #   pkgs.mkShell {
      #     name = "Rust-nightly";
      #     packages = packages;
      #     shellHook = ''
      #       echo "🦀🦀🦀🦀 hello Rust Nightly!"
      #       echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
      #     '';
      #   };
      #

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

      # tree = let
      #   packages = with pkgs; [
      #     tree-sitter
      #     prettierd
      #     emscripten
      #   ];
      # in
      #   pkgs.mkShell {
      #     name = "tree-sitter";
      #     packages = packages;
      #     shellHook = ''
      #       echo "🌳🌳🌳🌳 hello Tree-sitter!"
      #       echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
      #     '';
      #   };

      # nvim = let
      #   packages = with pkgs; [
      #     # gnumake
      #   ];
      # in
      #   pkgs.mkShell {
      #     name = "Nvim";
      #     packages = packages;
      #     shellHook = ''
      #       echo "🅽 🅽 🅽 🅽  hello Nvim!"
      #       echo "Packages: ${builtins.concatStringsSep "" (map (p: "  ${p.name or p.pname or "unknown"}") packages)}"
      #     '';
      #   };

      python = let
        packages = with pkgs; [
          (python312.withPackages (ps:
            with ps; [
              ipython
              pip
              virtualenv
              # editor/test tooling
              black
              isort
              ruff
              pytest
              debugpy
              # jupyter kernel (base, pip can add more)
              jupyterlab
              notebook
            ]))
          # LSPs & helpers as binaries (no pip needed)
          pyright
          # Native build deps when wheels aren't available
          cmake
          pkg-config
          # System libraries needed for native Python packages
          gcc-unwrapped.lib
          stdenv.cc.cc.lib
          zlib
          # Additional libraries often needed for ML packages
          libffi
          openssl
        ];
      in
        pkgs.mkShell {
          name = "Python ML";
          packages = packages;

          # Environment variables for native compilation
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
            pkgs.gcc-unwrapped.lib
            pkgs.stdenv.cc.cc.lib
            pkgs.zlib
            pkgs.libffi
            pkgs.openssl
          ];

          # Help pip find system libraries during compilation
          NIX_CFLAGS_COMPILE = "-I${pkgs.zlib.dev}/include -I${pkgs.libffi.dev}/include -I${pkgs.openssl.dev}/include";
          NIX_LDFLAGS = "-L${pkgs.zlib}/lib -L${pkgs.libffi}/lib -L${pkgs.openssl.out}/lib";

          shellHook = ''
            echo "🧠🤖 hello Python ML devshell!"
            # 1️⃣ Create .venv if missing
            if [ ! -d .venv ]; then
              echo "📦 Creating local .venv..."
              python -m venv .venv
            fi
            # 2️⃣ Activate .venv
            source .venv/bin/activate

            # 3️⃣ Only upgrade tools if needed
            if [ ! -f .venv/.setup_complete ]; then
              echo "🔧 Setting up Python environment..."
              pip install --upgrade pip setuptools wheel

              # 4️⃣ Install requirements (including ipykernel + ML packages)
              if [ -f requirements.txt ]; then
                echo "📥 Installing Python packages from requirements.txt..."
                pip install -r requirements.txt
              fi

              # 5️⃣ Register Jupyter kernel
              echo "📝 Registering ML venv kernel..."
              jupyter kernelspec uninstall ml-venv -y 2>/dev/null || true
              python -m ipykernel install --user --name=ml-venv --display-name "Python ML (.venv)"

              # Mark setup as complete
              touch .venv/.setup_complete
              echo "✅ ML environment ready with Jupyter kernel registered!"
            else
              echo "✅ ML environment already set up!"
            fi
          '';
        };
    });
  };
}

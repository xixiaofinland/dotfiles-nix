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
    # sfdx-nix = {
    #   url = "github:xixiaofinland/sfdx-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    #   inputs.flake-utils.follows = "flake-utils";
    # };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    nix-darwin,
    rust-overlay,
    # sfdx-nix,
  }: let
    hyprland-pc-user = "finxxi";
    hyprland-pc-hostname = "hyprland-pc";
    nixos-sys = "x86_64-linux";
    mac-user = "xixiao";
    mac-hostname = "Xis-MacBook-Pro";
    mac-sys = "x86_64-darwin";
    lib = nixpkgs.lib;
    cacheSubstituters = [
      "https://cache.nixos.org" # Official cache first
      "https://nix-community.cachix.org" # Community cache second
      "https://xixiaofinland.cachix.org" # Your personal cache
      "https://cachix.cachix.org" # Generic cachix
      "https://nixpkgs.cachix.org" # Last resort
    ];
    cacheTrustedPublicKeys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKayc="
      "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      "nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE="
    ];
    overlays = [
      rust-overlay.overlays.default
      (
        final: prev: {
          # sf = sfdx-nix.packages.${final.system}.sf;
          rustToolchainStable = final.rust-bin.stable.latest.default;
          rustToolchainNightly = final.rust-bin.nightly.latest.default;
        }
      )
    ];
    mkPkgs = {
      system,
      allowUnfree ? true,
      allowUnfreePredicate ? null,
    }:
      import nixpkgs {
        inherit system overlays;
        config =
          {
            inherit allowUnfree;
          }
          // (lib.optionalAttrs (allowUnfreePredicate != null) {
            inherit allowUnfreePredicate;
          });
      };
    mkHomeManagerNixosModule = userName: homeModule: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users."${userName}" = import homeModule;
    };
    mkHomeManagerDarwinModule = userName: homeModule: {
      home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.users."${userName}" = import homeModule;
    };
    mkNixosCacheModule = userName: {
      nix.settings = {
        substituters = cacheSubstituters;
        trusted-public-keys = cacheTrustedPublicKeys;
        trusted-users = [userName];
      };
    };
    mkDarwinNixModule = {
      pkgs,
      trustedUsers,
    }: {
      nix = {
        package = pkgs.nixVersions.stable; # pull in the nix binary from cache, NixOS doesn't need to do so
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
        settings = {
          trusted-substituters = cacheSubstituters;
          trusted-public-keys = cacheTrustedPublicKeys;
          trusted-users = trustedUsers;
        };
      };
    };
    nixos-baseModules = userName: homeModule: [
      ./modules/common-config.nix
      ./modules/nixos-config.nix
      home-manager.nixosModules.home-manager
      (mkHomeManagerNixosModule userName homeModule)
      (mkNixosCacheModule userName)
    ];
    forAllSystems = function:
      nixpkgs.lib.genAttrs [
        "${nixos-sys}"
        "${mac-sys}"
      ] (system:
        function (import nixpkgs {
          # inherit system overlays sfdx-nix;
          inherit system overlays;
        }));
  in {
    nixosConfigurations = {
      "${hyprland-pc-hostname}" = nixpkgs.lib.nixosSystem rec {
        system = "${nixos-sys}";
        pkgs = mkPkgs {
          inherit system;
          # Fixme: Nvida install still gives error
          # allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["obsidian" "nvidia-x11"];
          allowUnfree = true;
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
        pkgs = mkPkgs {
          inherit system;
          allowUnfreePredicate = pkg:
            builtins.elem (lib.getName pkg) ["obsidian"];
          # allowUnsupportedSystem = true; # todo: opencode too new issue, fix this for long term
          allowUnfree = true;
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
          (mkHomeManagerDarwinModule mac-user ./modules/home.nix)
          (mkDarwinNixModule {
            inherit pkgs;
            trustedUsers = ["root" "xixiao"];
          })
        ];
      };
    };

    devShells = forAllSystems (pkgs: rec {
      default = rust;

      rust = let
        packages = with pkgs; [
          rust-bin.stable.latest.default
          rust-analyzer

          clang
          cargo-tarpaulin
          cargo-watch
          cargo-expand
          mold
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

      anomaly-rust = let
        nativeLibs = with pkgs; [
          openssl
          onnxruntime
          zlib
        ];
      in
        pkgs.mkShell {
          name = "Rust";

          # Add tools needed for building C-linked crates
          nativeBuildInputs = with pkgs; [
            pkg-config
            cmake
            rust-bin.stable.latest.default
          ];

          buildInputs = nativeLibs ++ [pkgs.rust-analyzer];

          # Critical environment variables
          ORT_DYLIB_PATH = "${pkgs.onnxruntime}/lib/libonnxruntime.so";
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath nativeLibs;

          shellHook = ''
            echo "🏭 Industrial AI Environment: ONNX Dynamic Loading Enabled"
            export ORT_DYLIB_PATH="${pkgs.onnxruntime}/lib/libonnxruntime.so"
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
          ctags-lsp
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

      python = let
        packages = with pkgs; [
          (python312.withPackages (ps:
            with ps; [
              ipython
              pip
              virtualenv

              black
              isort
              ruff
              pytest
              debugpy

              jupyterlab
              notebook
              ipykernel

              # scientific/ML libs
              numpy
              matplotlib
              ipympl # <- enables %matplotlib widget
              pandas
              scikit-learn
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
              echo "📦 Creating local .venv with system packages..."
              python -m venv --system-site-packages .venv
            fi

            # 2️⃣ Activate .venv
            source .venv/bin/activate
            export PIP_REQUIRE_VIRTUALENV=true

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

      ml = let
        pythonEnv = pkgs.python312.withPackages (ps:
          with ps; [
            torch
            torchvision
            onnx
            onnxruntime # AI Core
            numpy
            matplotlib
            pillow
            scikit-learn
            pandas # Science
            ipython
            black
            ruff
            pytest # Dev Tools

            matplotlib
            pillow
          ]);
        systemLibs = with pkgs; [stdenv.cc.cc.lib zlib libGL glib libffi openssl];
      in
        pkgs.mkShell {
          name = "Python Industrial AI";
          packages = [pythonEnv pkgs.pyright pkgs.cmake pkgs.pkg-config] ++ systemLibs;
          LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath systemLibs;
          shellHook = ''
            echo "🏭 Industrial AI Phase 1 (Python Brain)"

            # Create the venv with access to Nix packages
            if [ ! -d .venv-ml ]; then
              python -m venv --system-site-packages .venv-ml
            fi

            source .venv-ml/bin/activate

            # This ensures Python looks at Nix packages first
            export PYTHONPATH="$PYTHONPATH:$(python -c 'import site; print(site.getsitepackages()[0])')"
            export PYTHONDONTWRITEBYTECODE=1
          '';
        };
    });
  };
}

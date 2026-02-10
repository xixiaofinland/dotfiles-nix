# Agent Guidelines for dotfiles-nix

This document provides essential information for AI coding agents working in this NixOS/nix-darwin dotfiles repository.

## Repository Overview

This is a personal dotfiles repository using Nix Flakes to manage configurations for both NixOS (Linux) and nix-darwin (macOS). The repository uses home-manager for user-level configurations and provides multiple development shells for different languages and projects.

**Primary Technologies:**
- Nix Flakes for declarative system configuration
- Home Manager for dotfile management
- Fish shell as the default shell
- Tmux for terminal multiplexing
- Neovim as the primary editor

## Build/Deploy Commands

### System Rebuild

**NixOS (Linux):**
```bash
sudo nixos-rebuild switch --flake ~/dotfiles-nix/.#hyprland-pc
```

**macOS (Darwin):**
```bash
darwin-rebuild switch --flake ~/dotfiles-nix
```

### Development Shells

Enter a development shell:
```bash
nix develop                          # Default (Rust)
nix develop .#rust                   # Rust development
nix develop .#python                 # Python ML with Jupyter
nix develop .#afmt                   # Afmt (Rust + WASM)
nix develop .#blog                   # mdbook blog
nix develop .#sf                     # Salesforce development
nix develop .#nvim                   # Neovim development
nix develop .#anomaly-rust           # Rust with ONNX Runtime
```

### Flake Management

```bash
nix flake check                      # Validate flake configuration
nix flake update                     # Update all inputs
nix flake lock --update-input <name> # Update specific input (e.g., nixpkgs, rust-overlay)
nix flake show                       # Show flake outputs
```

### Listing/Rolling Back Generations

**NixOS:**
```bash
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
sudo nix-env --switch-generation 93 --profile /nix/var/nix/profiles/system
```

**macOS:**
```bash
darwin-rebuild --list-generations
darwin-rebuild switch --switch-generation 124
```

### Garbage Collection

Automatic GC is enabled (weekly on NixOS, weekly on Darwin), but can be run manually:
```bash
nix-collect-garbage --delete-older-than 14d
```

## Code Style Guidelines

### Nix Code Style

**Formatting:**
- Use `alejandra` for Nix code formatting (available in home.packages)
- Indentation: 2 spaces (no tabs)
- Maximum line length: ~100 characters (flexible)

**Import Structure:**
```nix
{
  config,
  lib,
  pkgs,
  ...
}: {
  # Module content
}
```

**Attribute Sets:**
- Use `with pkgs;` sparingly, prefer explicit `pkgs.` prefix for clarity
- Use `let...in` for local bindings
- Keep attribute sets organized and grouped logically

**Example:**
```nix
{
  pkgs,
  ...
}: let
  customPackage = pkgs.rustPlatform.buildRustPackage {
    pname = "example";
    version = "0.1.0";
  };
in {
  home.packages = with pkgs; [
    customPackage
    ripgrep
    fd
  ];
}
```

### Naming Conventions

**Files:**
- Module files: `kebab-case.nix` (e.g., `home-core.nix`, `mac-config.nix`)
- Use descriptive names that indicate purpose

**Variables:**
- camelCase for Nix variables (e.g., `nixos-sys`, `hyprland-pc-user`)
- Use meaningful, descriptive names
- Constants in all caps with underscores (e.g., `LANG`, `NPM_CONFIG_PREFIX`)

**Functions:**
- Prefix helper functions with `mk` (e.g., `mkPkgs`, `mkHomeManagerNixosModule`)
- Use descriptive names indicating what they create/do

### Module Organization

**Standard module structure:**
1. Imports
2. Let bindings (local variables, custom packages)
3. Main configuration (home.packages, programs.*, services.*)
4. Session variables and environment
5. Shell configuration (aliases, functions)

**File organization in `/modules`:**
- `common-config.nix` - Shared between NixOS and Darwin
- `nixos-config.nix` - NixOS-specific settings
- `mac-config.nix` - Darwin-specific settings  
- `home-*.nix` - Home Manager configurations
- `*-config.nix` - Hardware or platform-specific configs

### Comments

- Use `#` for single-line comments
- Add explanatory comments for non-obvious configurations
- Document why something is done, not just what
- Use section comments to organize large files:

```nix
# ── Terminal settings
set -g default-terminal "tmux-256color"

# BUG: describe the bug and link to issue if available
# https://github.com/nix-community/home-manager/issues/5952
```

### Error Handling

- Prefer declarative safety (use `lib.optionalAttrs`, `lib.mkIf`)
- Use conditional expressions for platform-specific code:
  ```nix
  pinentry = if pkgs.stdenv.isDarwin
             then pkgs.pinentry_mac
             else pkgs.pinentry-tty;
  ```
- Test configurations before committing with `nix flake check`

### Git Commit Style

Based on recent commits, use:
- Very concise commit messages (often just `+` for incremental work)
- Use conventional prefixes when meaningful: `refactor:`, `fix:`, `feat:`
- Keep commits small and atomic
- Common abbreviations:
  - `aa` = add all and commit with message `+`
  - `app` = git push

### Dependencies and Inputs

**Flake inputs used:**
- `nixpkgs` - NixOS/nixpkgs unstable
- `home-manager` - User environment management
- `nix-darwin` - macOS system configuration
- `rust-overlay` - Rust toolchains

**Custom overlays:**
- Define overlays in `flake.nix` for custom package versions
- Use `rust-bin.stable.latest.default` for stable Rust
- Use `rust-bin.nightly.latest.default` for nightly Rust

### Testing Changes

Before committing configuration changes:

1. Check syntax: `nix flake check`
2. Test locally: `nixos-rebuild test` or `darwin-rebuild build`
3. Only switch when confident: `switch` command
4. Keep generations limit low (5) to save space

## Common Patterns

### Adding a New Package

1. Add to `home.packages` in `modules/home-core.nix`
2. Run `nix flake check` to validate
3. Rebuild system configuration

### Adding a New Development Shell

1. Add to `devShells` in `flake.nix`
2. Define packages in a `let` binding
3. Include a descriptive `shellHook`
4. Test with `nix develop .#<name>`

### Adding a New Dotfile

1. Place the file in `dotfiles/` directory
2. Reference in `modules/home-files.nix`:
   ```nix
   home.file.".myconfig".source = ../dotfiles/.myconfig;
   ```
3. For directories, use `recursive = true`

## Notes

- **DO NOT** modify git config programmatically - user manages `.gitconfig` manually
- **DO NOT** use `--no-verify` or skip hooks unless explicitly requested
- **AVOID** force pushes to main/master branches
- The repository uses cachix for binary caching (xixiaofinland.cachix.org)
- Home Manager manages most user-level configurations
- System-level changes require `sudo` on NixOS but not on Darwin
- Python development shell auto-creates virtualenv in `.venv/` with Jupyter kernel

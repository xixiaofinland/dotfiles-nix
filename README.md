# Dotfiles with Nix

This repository contains my personal configuration files (dotfiles) managed using Nix Flakes. It supports both macOS and NixOS on a WSL2 subsystem in Windows.

⚠️ It's important to understand what the code does before applying to your own system. It has a learning curve to use Nix, take action rigorously!

## Features

- **Nix Flakes**: Manage dependencies and configurations.
- **Cross-Platform**: Works on macOS and NixOS (WSL2).
- **Custom Modules**: Modular configuration for easy customization.

## Installation
1. **Prerequistes**:
    - Nix: [Use this 3rd party script](https://zero-to-nix.com/concepts/nix-installer) (recommended) or follow the [official Nix installation guide](https://nixos.org/download.html).
    - Home manager: [Github repo](https://github.com/nix-community/home-manager)
    - Nix-darwin (for MacOS): [Github repo](https://github.com/LnL7/nix-darwin)

2. **Clone the Repository**:
    ```bash
    git clone https://github.com/xixiaofinland/dotfiles-nix.git ~/dotfiles-nix
    cd ~/dotfiles-nix
    ```
3. **Activate Flakes**:
   - If you used the official Nix installation guide, make sure to enable flakes by adding `experimental-features = nix-command flakes` to your `~/.config/nix/nix.conf`, or whatever way to enable the the `flake` feature.
   - If you used the 3rd party script, `flake` should have been auto-enabled for you.

6. **Commands**:

   Nix update with `flake.lock`:
   ```bash
   nix flake update # update everything
   nix flake lock --update-input sfdx-nix --update-input rust-overlay # update only specified packages

   ```
   In NixOS:
    ```bash
    sudo nixos-rebuild switch --flake ~/dotfiles-nix/
    sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
    sudo nix-env --switch-generation 93 --profile /nix/var/nix/profiles/system
    ```

   In MacOS:
    ```bash
    darwin-rebuild switch --flake ~/dotfiles-nix
    darwin-rebuild --list-generations # list previous builds
    darwin-rebuild switch --switch-generation 124 # roll back to the number 124 from the above list
    ```

## Structure

- **flake.nix**: Main entry point for Nix Flake.
- **modules/**: Contains custom Nix modules.
- **dotfiles/**: Holds individual dotfiles for various applications.

## Debug

### In MacOS Darwin

"warning: ignoring the client-specified setting 'trusted-public-keys', because it is a restricted setting and you are not a trusted user"

Make sure `/etc/nix/nix.conf` has correct content especially no duplicate entries, for example:

```
trusted-users = root xixiao
trusted-substituters = https://xixiaofinland.cachix.org https://cachix.cachix.org https://nixpkgs.cachix.org
trusted-public-keys = xixiaofinland.cachix.org-1:GORHf4APYS9F3nxMQRMGGSah0+JC5btI5I3CKYfKayc= cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM= nixpkgs.cachix.org-1:q91R6hxbwFvDqTSDKwDAV4T5PxqXGxswD8vhONFMeOE= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=
```

### NixOS in Win WSL2

Sometimes the sudo permission is gone mysteriously

- `wsl --list --verbose`
- `wsl -d NixOS -u root`
- `ls -l /run/wrappers/bin/sudo`
- `sudo chmod 4755 /run/wrappers/bin/sudo` 

## Contributing

Feel free to open issues or submit pull requests. Contributions are welcome!

## License

This repository is licensed under the MIT License.

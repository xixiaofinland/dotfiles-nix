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

6. **Apply Configurations**:
   In NixOS:
    ```bash
    sudo nixos-rebuild switch --flake ~/dotfiles-nix/
    ```

   In MacOS:
    ```bash
    nix run nix-darwin -- switch --flake ~/dotfiles-nix/
    ```   

## Structure

- **flake.nix**: Main entry point for Nix Flake.
- **modules/**: Contains custom Nix modules.
- **dotfiles/**: Holds individual dotfiles for various applications.

## Contributing

Feel free to open issues or submit pull requests. Contributions are welcome!

## License

This repository is licensed under the MIT License.

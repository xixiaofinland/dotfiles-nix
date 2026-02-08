{
  config,
  lib,
  ...
}: let
  nvimConfigDir = "${config.home.homeDirectory}/dotfiles-nix/dotfiles/nvim_config";
in {
  # trade impurity for convenience as I need to update nvim config quite frequently!
  xdg.configFile."nvim" = {
    source =
      config.lib.file.mkOutOfStoreSymlink nvimConfigDir;
    recursive = true;
  };

  # darwin + home manager doesn't automatically link the new files from Nvim config folder.
  home.activation = {
    linkNewNvimFiles = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Linking new Neovim configuration files..."
      find "${nvimConfigDir}" -type f | while read file; do
        relative_path="''${file#${nvimConfigDir}/}"
        target="$HOME/.config/nvim/$relative_path"
        if [ ! -e "$target" ]; then
          $DRY_RUN_CMD mkdir -p "$(dirname "$target")"
          $DRY_RUN_CMD ln -s $VERBOSE_ARG "$file" "$target"
          echo "Linked new file: $relative_path"
        fi
      done
    '';
  };
}

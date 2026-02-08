{
  ...
}: {
  home.file = {
    ".finter".source = ../dotfiles/.finter;
    ".gitconfig".source = ../dotfiles/.gitconfig;
    ".alacritty.toml".source = ../dotfiles/.alacritty.toml;
    ".ignore".source = ../dotfiles/.ignore;
    ".config/direnv/direnv.toml".source = ../dotfiles/direnv/direnv.toml;
    ".tmux_init_actions.sh".source = ../dotfiles/.tmux_init_actions.sh;
    ".config/hypr/hyprland.conf".source = ../dotfiles/hypr/hyprland.conf;
    ".config/hypr/hyprpaper.conf".source = ../dotfiles/hypr/hyprpaper.conf;
    ".config/hypr/random_wall.sh".source = ../dotfiles/hypr/random_wallpaper.sh;
    "Wallpapers" = {
      source = ../dotfiles/Wallpapers;
      recursive = true;
    };
    ".config/waybar/config".source = ../dotfiles/hypr/waybar/config;
    ".config/waybar/style.css".source = ../dotfiles/hypr/waybar/style.css;
  };
}

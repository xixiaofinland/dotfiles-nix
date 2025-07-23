{ pkgs, ... }: {
  home.packages = with pkgs; [
    dunst # notification daemon
    brightnessctl # screen brightness control
    pavucontrol # audio control
    networkmanagerapplet
    swaylock-effects # lock screen (optional)
    grim
    slurp
    wl-clipboard
  ];

  xdg.configFile = {
    "hypr/hyprland.conf".source = ../dotfiles/hypr/hyprland.conf;
  };

  programs.waybar.enable = true;
  programs.wofi.enable = true;
  programs.foot.enable = true;
}

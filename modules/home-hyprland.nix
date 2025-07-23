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

    alacritty
  ];

  programs.waybar.enable = true;
  programs.wofi.enable = true;
}

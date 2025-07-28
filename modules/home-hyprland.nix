{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono

    xfce.thunar # file manager

    libnotify # notify-send cli
    mako # notification daemon

    brightnessctl # screen brightness control

    networkmanagerapplet

    swaylock-effects # lock screen (optional)

    grim
    slurp
    wl-clipboard

    alacritty
    brave

    blueman # GUI Bluetooth manager
    bluez
    bluez-tools

    pavucontrol # audio control

    udiskie

    pamixer # Audio vol up/down
    pulsemixer # optional TUI tool

    unzip
  ];

  programs.waybar.enable = true;
  programs.wofi.enable = true;
}

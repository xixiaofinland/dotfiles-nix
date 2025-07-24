{pkgs, ...}: {
  home.packages = with pkgs; [
    pkgs.nerd-fonts.jetbrains-mono

    dunst # notification daemon

    brightnessctl # screen brightness control

    networkmanagerapplet

    swaylock-effects # lock screen (optional)

    grim
    slurp
    wl-clipboard

    alacritty
    brave

    blueman # GUI Bluetooth manager
    bluez-tools
    pulseaudio # optional, but useful tools

    pavucontrol # audio control

    udiskie

    pamixer # Audio vol up/down
    pulsemixer # optional TUI tool

    unzip
  ];

  programs.waybar.enable = true;
  programs.wofi.enable = true;
}

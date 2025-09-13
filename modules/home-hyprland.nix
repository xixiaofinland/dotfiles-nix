{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono

    # chinese character support
    noto-fonts-cjk-sans
    noto-fonts
    wqy_zenhei
    wqy_microhei

    xfce.thunar # file manager

    libnotify
    mako # notification daemon

    brightnessctl # screen brightness control

    networkmanagerapplet

    swaylock-effects # lock screen (optional)

    grim
    slurp
    wl-clipboard

    wl-screenrec
    davinci-resolve

    brave

    blueman # GUI Bluetooth manager
    bluez
    bluez-tools

    pavucontrol # audio control

    udiskie

    pamixer # Audio vol up/down
    pulsemixer # optional TUI tool

    hyprpaper

    unzip
    anki-bin
    # transmission_4-qt
    # qbittorrent-enhanced
    qbittorrent
    vlc
    kdePackages.okular #pdf reader
  ];
  fonts.fontconfig.enable = true;

  programs.waybar.enable = true;
  programs.wofi.enable = true;

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      anchor = "top-right";
    };
  };
}

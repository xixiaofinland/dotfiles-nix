{pkgs, ...}: {
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono

    # Chinese character support
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
    wf-recorder # screen recorder

    brave

    blueman # GUI Bluetooth manager
    bluez
    bluez-tools

    pavucontrol # audio control

    udiskie

    pamixer # Audio volume control
    pulsemixer # optional TUI tool

    hyprpaper

    unzip
    anki-bin
    qbittorrent
    kdePackages.okular # PDF reader
    pinta # picture tool

    alacritty

    # Docker CLI tools
    # docker
    # docker-compose
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

  # Fix VLC freeze on Wayland
  programs.vlc = {
    enable = true;
    package = pkgs.vlc;
    extraWrapperArgs = ["--set" "QT_QPA_PLATFORM" "xcb"];
  };
}

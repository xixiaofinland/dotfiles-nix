{pkgs, ...}: let
  # Wrapped VLC to fix unresponsive UI bug under Wayland
  vlc-xwayland = pkgs.symlinkJoin {
    name = "vlc-xwayland";
    paths = [pkgs.vlc];
    buildInputs = [pkgs.makeWrapper];
    postBuild = ''
      wrapProgram $out/bin/vlc \
        --set QT_QPA_PLATFORM xcb
    '';
  };
in {
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

    vlc-xwayland

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
}

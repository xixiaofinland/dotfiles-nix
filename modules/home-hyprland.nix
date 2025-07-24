{pkgs, ...}: {
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
    brave
    pkgs.nerd-fonts.jetbrains-mono
    blueman # GUI Bluetooth manager
    udiskie
  ];

  programs.waybar.enable = true;
  programs.wofi.enable = true;
}

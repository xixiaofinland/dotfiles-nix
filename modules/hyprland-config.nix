{
  pkgs,
  lib,
  user,
  hostName,
  ...
}: {
  imports = [
    ./hyprland-pc-hardware-configuration.nix
  ];

  networking.hostName = "${hostName}";

  # Enable networking
  networking.networkmanager.enable = true;

  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    initialPassword = "changeme";
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
  };

  # ── Hyprland Wayland session ─────────────
  programs.hyprland.enable = true;
  programs.xwayland.enable = true;

  # ── xdg-desktop-portal for screen share, file picker, etc.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  };

  # ── Optional: greetd for auto-login GUI (TTY alternative)
  # services.greetd = {
  #   enable = true;
  #   settings.default_session = {
  #     command = "Hyprland";
  #     user = user;
  #   };
  # };

  # ── Essential GUI packages (minimal bar + launcher) ─
  environment.systemPackages = with pkgs; [
    waybar # status bar
    wofi # launcher
    foot # terminal
    grim
    slurp # screenshot tools
    wl-clipboard # clipboard support
  ];

  # ── Fix for some Electron apps in Wayland ─
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}

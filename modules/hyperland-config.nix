{
  pkgs,
  lib,
  ...
}: {
  networking.hostName = "hyprland";

  users.users.nixos = {
    isNormalUser = true;
    shell = pkgs.fish;
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
  };

  # home-manager.users.finxxi = import ../home.nix;

  programs.hyprland.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
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
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "Hyprland";
      user = "finxxi";
    };
  };

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

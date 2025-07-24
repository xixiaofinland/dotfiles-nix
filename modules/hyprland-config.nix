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

  services.blueman.enable = true; # optional GUI manager (recommended for desktops)
  hardware.bluetooth.enable = true; # enables kernel support
  hardware.bluetooth.powerOnBoot = true; # auto-turn on

  services.udisks2.enable = true; # System-level service
  services.dbus.enable = true; # Needed for all desktop interaction

  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    initialPassword = "changeme";
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
  };

  # Use proprietary Nvidia drivers
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    powerManagement.enable = false;
    open = false; # use proprietary
  };

  # Kernel and Wayland-specific tweaks
  environment.variables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    __GL_GSYNC_ALLOWED = "0";
    WLR_RENDERER_ALLOW_SOFTWARE = "1"; # fallback renderer
    NIXOS_OZONE_WL = "1"; # Enable Wayland for Electron apps
    MOZ_ENABLE_WAYLAND = "1"; # Not for Brave, but good for Firefox
  };

  # ── Fix for some Electron apps in Wayland ─
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Hyprland + XWayland
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
      user = user;
    };
  };
}

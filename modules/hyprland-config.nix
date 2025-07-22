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

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  boot.extraModulePackages = [
    config.boot.kernelPackages.nvidia_x11
  ];
  boot.blacklistedKernelModules = [
    "nouveau"
    "rivafb"
    "nvidiafb"
    "rivatv"
    "nv"
    "uvcvideo"
  ];
  services.xserver.videoDrivers = [
    "nvidia"
    "intel"
  ];

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest; # `latest` is `555.58.02` currently

    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;

    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
}

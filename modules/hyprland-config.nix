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

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.nvidia.prime = {
    #sync.enable = true; # sync mode, gpu will stay active
    offload = {
      enable = true;
      enableOffloadCmd = true;
    };
    # Make sure to use the correct Bus ID values for your system!
    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
  };

  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

environment.variables = {
  __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  LIBVA_DRIVER_NAME        = "nvidia";
  WLR_NO_HARDWARE_CURSORS  = "1";   # fixes white boxes/flicker
};

}

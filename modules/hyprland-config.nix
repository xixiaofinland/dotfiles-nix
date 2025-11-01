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

  # Enable networking and use nmtui or nmcli to setup wireless/wifi
  networking.networkmanager.enable = true;

  hardware.enableAllFirmware = true;
  hardware.firmware = with pkgs; [linux-firmware];
  boot.kernelModules = ["rt2800usb"];

  hardware.bluetooth.enable = true; # enables kernel support
  hardware.bluetooth.powerOnBoot = true; # auto-turn on

  users.users.${user} = {
    isNormalUser = true;
    shell = pkgs.fish;
    initialPassword = "changeme";
    extraGroups = ["wheel" "networkmanager" "video" "audio"];
    # extraGroups = ["wheel" "networkmanager" "video" "audio" "docker"];
  };

  # Docker daemon configuration
  # virtualisation.docker.enable = true;
  # virtualisation.docker.enableOnBoot = true;

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

  # Hyprland + XWayland
  programs.hyprland.enable = true;
  programs.xwayland.enable = true;

  # ── xdg-desktop-portal for screen share, file picker, etc.
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-hyprland];
  };

  # Use proprietary Nvidia drivers
  services.xserver.videoDrivers = ["nvidia"];

  # ── Optional: greetd for auto-login GUI (TTY alternative)
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "Hyprland";
      user = user;
    };
  };

  # PipeWire support for Bluetooth
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    extraConfig.pipewire."bluez5" = {
      "enabled" = true;
      "properties" = {
        "bluez5.auto-connect" = ["a2dp_sink"];
      };
    };
  };

  # Bluetooth service
  services.blueman.enable = true; # optional GUI manager (recommended for desktops)
  services.pulseaudio.enable = false;

  services.udisks2.enable = true; # System-level service
  services.dbus.enable = true; # Needed for all desktop interaction

  systemd.user.services.bluetooth-autoconnect = {
    description = "Auto-connect Stanmore Bluetooth speaker with delay";
    after = ["graphical-session.target"];
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash -c 'sleep 10 && ${pkgs.bluez}/bin/bluetoothctl connect 54:B7:E5:4E:1A:D7'";
    };
  };

  systemd.user.services.udiskie = {
    description = "Auto-mount USB devices";
    wantedBy = ["default.target"];
    serviceConfig = {
      ExecStart = "${pkgs.udiskie}/bin/udiskie --no-notify";
    };
  };

  # Ollama service
  # services.ollama = {
  #   enable = true;
  #   acceleration = "cuda";   # NVIDIA
  # };
}

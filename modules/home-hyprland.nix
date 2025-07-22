{ pkgs, ... }:

{
  # Pull in everything that generic home.nix already provides
  imports = [ ./home.nix ];

  # Extra desktop utilities that are **not** in hyperland-config.nix
  home.packages = with pkgs; [
    hyprpaper        # wallpaper daemon
    mako             # notifications
    swaybg           # static background helper (fallback)
  ];

  ## Per-user Hyprland settings  ─────────────────────────────
  wayland.windowManager.hyprland = {
    enable = true;

    settings = {
      # autostart
      exec-once = [
        "hyprpaper"
        "waybar"
        "mako"
      ];

      # a couple of safe starter keybinds
      bind = [
        "SUPER, Return, exec, foot"
        "SUPER, Q, killactive"
        "SUPER SHIFT, Q, exit"
      ];
    };
  };

  ## Notification daemon
  services.mako = {
    enable = true;
    font   = "JetBrainsMono Nerd Font 10";
    anchor = "top-right";
  };
}

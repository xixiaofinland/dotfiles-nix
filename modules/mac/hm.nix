{
  config,
  pkgs,
  ...
}: {
  # home.username = "xixiao";
  # home.homeDirectory = "/Users/xixiao";

  home.packages = with pkgs; [
    # nixpkgs-fmt
    # fzf
    # ripgrep
    # zoxide
    # fd
    tree
  ];

  home.file = {
    ".lazy-lock.json".source = ../../dotfiles/.lazy-lock.json;
    # ".gitconfig".source = ./dotfiles/.gitconfig;
    # ".alacritty.toml".source = ./dotfiles/.alacritty.toml;
    # ".ignore".source = ./dotfiles/.ignore;
    # ".config/nvim" = {
    #   source = ./dotfiles/nvim;
    #   recursive = true;
    # };
  };

  # xdg.configFile."nvim" = {
  #   source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles-nix/dotfiles/nvim";
  #   recursive = true;
  # };

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
  };

  home.sessionPath = [
    # "$HOME/.cargo/bin"
  ];

  home.stateVersion = "24.05";
  programs.home-manager.enable = true;
}

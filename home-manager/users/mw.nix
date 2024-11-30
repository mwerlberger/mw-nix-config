{pkgs, ...}: {
  # this is internal compatibility configuration
  # for home-manager, don't change this!
  home.stateVersion = "23.05";
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    pkgs.micromamba
    pkgs.rectangle
    pkgs.ripgrep
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.meslo-lg
    pkgs.nerd-fonts.inconsolata
    pkgs.nerd-fonts.hack
    pkgs.ghstack
    pkgs.git-branchless
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}

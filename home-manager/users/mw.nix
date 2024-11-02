{pkgs, ...}: {
  # this is internal compatibility configuration 
  # for home-manager, don't change this!
  home.stateVersion = "23.05";
  # Let home-manager install and manage itself.
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    pkgs.micromamba
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
  };
}

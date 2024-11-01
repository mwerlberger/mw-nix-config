{
  description = "Manuel's system configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.05"
    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
        url = "github:LnL7/nix-darwin";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = {pkgs, ... }: {

        services.nix-daemon.enable = true;
        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility. please read the changelog
        # before changing: `darwin-rebuild changelog`.
        system.stateVersion = 5;

        # The platform the configuration will be used on.
        # If you're on an Intel system, replace with "x86_64-darwin"
        nixpkgs.hostPlatform = "aarch64-darwin";

        # Declare the user that will be running `nix-darwin`.
        users.users.$USER = {
            name = "mw";
            home = "/Users/mw";
        };

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;
	programs.fish.enable = true;

        environment.systemPackages = [
          pkgs.neofetch
	  pkgs.neovim
	  pkgs.bat
	  pkgs.nushell
	  pkgs.git
	];
    };
  in
  {
    darwinConfigurations."mw-mb-air" = nix-darwin.lib.darwinSystem {
      modules = [
         configuration
      ];
    };
  };
}

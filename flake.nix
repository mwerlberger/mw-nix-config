{
  description = "Manuel's system configuration";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nixpkgs, nix-darwin, home-manager }:
  let
    configuration = {pkgs, ... }: {
    	nixpkgs.config.allowUnfree = true;
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
        users.users.mw = {
            name = "mw";
            home = "/Users/mw";
        };

        # Create /etc/zshrc that loads the nix-darwin environment.
        # programs.zsh.enable = true;
	programs.fish.enable = true;

        security.pam.enableSudoTouchIdAuth = true;

	system.defaults = {
	  # minimal dock
	  dock = {
	    autohide = true;
	    orientation = "bottom";
	    show-process-indicators = true;
	    show-recents = false;
	    static-only = false;
	    minimize-to-application = true;
	    mru-spaces = false;
	    persistent-apps = [
	      "/Applications/WezTerm.app"
	      "/Applications/Visual Studio Code.app"
	      "/Applications/Arc.app"
	      "/Applications/Safari.app"
	      "/Applications/Calendar.app"
	      "/Applications/Photos.app"
	      "/Applications/1Password.app"
	    ];
	    persistent-others = [
	      "~/Documents"
	      "~/Downloads"
	      "/Applications"
	    ];
	  };
	  # a finder that tells me what I want to know and lets me work
	  finder = {
	    AppleShowAllExtensions = true;
	    ShowPathbar = true;
	    ShowStatusBar = true;
	    FXEnableExtensionChangeWarning = false;
	  };
	  # Tab between form controls and F-row that behaves as F1-F12
	  NSGlobalDomain = {
	    InitialKeyRepeat = 10;
	    KeyRepeat = 1;
	    # AppleKeyboardUIMode = 3;
	    "com.apple.keyboard.fnState" = true;
	    "com.apple.swipescrolldirection" = false;
	    "com.apple.mouse.tapBehavior" = 1;
	    "com.apple.trackpad.forceClick" = true;
	  };
	  loginwindow.LoginwindowText = "MacBook powered by Nix";
	  spaces.spans-displays = false;
	  trackpad = {
	    Clicking = true;
	    TrackpadRightClick = true;
	  };
	};


        environment.systemPackages = [
          pkgs.neofetch
	  pkgs.neovim
	  pkgs.bat
	  pkgs.nushell
	  pkgs.git
	  pkgs.arc-browser
	  pkgs.wezterm
	];
    };
  in
  {
    darwinConfigurations."mw-mb-air" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager  {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          # home-manager.users.mw = homeconfig;
	  home-manager.users.mw = import ./home-manager/users/mw.nix;
        }
      ];
    };
  };
}

{
  description = "Manuel's system configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # Nix stable channel, for packages that break with nixpkgs-unstable
    # nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";

    darwin.url = "github:LnL7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    mac-app-util.url = "github:hraban/mac-app-util";

    # Nixvim style config for neovim. I might want to fork that later.
    neovim.url = "github:fred-drake/neovim";

    # custom flakes
    wezterm.url = "github:wez/wezterm/main?dir=nix";
    wezterm.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    darwin,
    home-manager,
    mac-app-util,
    neovim,
    wezterm,
  } @ inputs: let
    inherit (self) outputs;

    # Function to create Neovim packages with unique names
    mkNeovimPackages = pkgs: neovimPkgs: let
      mkNeovimAlias = name: pkg:
        pkgs.runCommand "neovim-${name}" {} ''
          mkdir -p $out/bin
          ln -s ${pkg}/bin/nvim $out/bin/nvim-${name}
        '';
    in
      builtins.mapAttrs mkNeovimAlias neovimPkgs;

    configuration = {pkgs, ...}: {
      nixpkgs.config.allowUnfree = true;
      services.nix-daemon.enable = true;
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility. please read the changelog
      # before changing: `darwin-rebuild changelog`.
      system.stateVersion = 4;

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
          mru-spaces = true;
          persistent-apps = [
            "/Applications/Nix Apps/WezTerm.app"
            "/Applications/Visual Studio Code.app"
            "/Applications/Nix Apps/Arc.app"
            "/Applications/Safari.app"
            "/Applications/Nix Apps/Numi.app"
            "/System/Applications/Calendar.app"
            "/System/Applications/Reminders.app"
            "/System/Applications/Photos.app"
            "/System/Applications/Music.app"
            "/Applications/1Password.app"
          ];
          persistent-others = [
            "/Users/mw/Documents"
            "/Users/mw/Downloads"
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
        loginwindow.LoginwindowText = "MacBook Air powered by Nix Darwin";
        spaces.spans-displays = false;
        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
        };
      };

      environment.systemPackages = [
        inputs.wezterm.packages.${pkgs.system}.default
        pkgs.neofetch
        pkgs.neovim
        pkgs.bat
        pkgs.nushell
        pkgs.git
        pkgs.arc-browser
        pkgs.numi
        pkgs.vlc-bin-universal
        pkgs.iina
        pkgs.maccy
        pkgs.raycast
      ];

      homebrew = {
        enable = true;
        # onActivation.cleanup = "uninstall";

        taps = [];
        brews = ["cowsay"];
        casks = [];
      };
    };
  in {
    darwinConfigurations."mw-mb-air" = darwin.lib.darwinSystem {
      modules = [
        configuration
        mac-app-util.darwinModules.default
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.sharedModules = [
            mac-app-util.homeManagerModules.default
          ];
          home-manager.users.mw.imports = [
            ./home-manager/users/mw.nix
            ({pkgs, ...}: {
              home.packages =
                (builtins.attrValues (mkNeovimPackages pkgs inputs.neovim.packages.${pkgs.system}))
                ++ [inputs.neovim.packages.${pkgs.system}.default];
            })
          ];
          # home-manager.users.mw = import ./home-manager/users/mw.nix;
        }
      ];
    };
  };
}

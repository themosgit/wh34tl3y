{
  description = "wheatley nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  let
    configuration = { pkgs, config, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.neovim
	  pkgs.kitty
	  pkgs.tmux
	  pkgs.btop
	  pkgs.mkalias #used for spotlight indexing
	  pkgs.firefox
	  pkgs.syncthing-macos
	  pkgs.keepassxc
	  pkgs.tailscale
	  pkgs.discord
	  pkgs.thunderbird
	  pkgs.spotify
        ];

       homebrew = {
	    enable = true;
      	    masApps = {
	      "word" = 462054704;
	      "excel" = 462058435;
	      "powerpoint" = 462062816;
	   };
	   onActivation.cleanup = "zap";
	   onActivation.autoUpdate = true;
	   onActivation.upgrade = true;
      };

      fonts.packages = 
        [ pkgs.nerd-fonts.jetbrains-mono
	];

      system.defaults = {
      	dock.tilesize = 54;
      	dock.autohide = true;
	dock.persistent-apps = [
		"${pkgs.kitty}/Applications/Kitty.app"
		"${pkgs.thunderbird}/Applications/Thunderbird.app"
		"${pkgs.discord}/Applications/Discord.app"
		"${pkgs.firefox}/Applications/Firefox.app"
		"${pkgs.spotify}/Applications/Spotify.app"
	];
	WindowManager.EnableTiledWindowMargins = false;
	finder.FXPreferredViewStyle = "clmv";
	loginwindow.GuestEnabled = false;
	NSGlobalDomain.AppleICUForce24HourTime = true;
	NSGlobalDomain.KeyRepeat = 2;
      };

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      services.openssh.enable = true;
      services.tailscale.enable = true;
      
      system.keyboard.enableKeyMapping = true;
      system.keyboard.remapCapsLockToEscape = true;
      security.pam.enableSudoTouchIdAuth = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      system.primaryUser = "themos";

      users.user.themos = {
      	home = "/Users/themos";
      };

      nixpkgs.config.allowUnfree = true;

      #used to index symlinks with spotlight
      system.activationScripts.applications.text =
      let
      	env = pkgs.buildEnv {
	    name = "system-applications";
	    paths = config.environment.systemPackages;
	    pathsToLink = "/Applications";
      	};
	in
  	pkgs.lib.mkForce ''
  	    # Set up applications.
	    echo "setting up /Applications..." >&2
	    rm -rf /Applications/Nix\ Apps
	    mkdir -p /Applications/Nix\ Apps
	    find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
	    while read -r src; do
		app_name=$(basename "$src")
		echo "copying $src" >&2
    		${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
  	    done
         '';
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#wh34tl3y
    darwinConfigurations."wh34tl3y" = nix-darwin.lib.darwinSystem {
      modules = [ 
      	configuration

	inputs.home-manager.darwinModules.home-manager {
		nixpkgs = nixpkgsConfig;

		home-manager.useGlobalPkgs = true;
		home-manager.useUserPackages = true;
		home-manager.users.themos = import ./nix/home.nix
	}

	nix-homebrew.darwinModules.nix-homebrew
	{
	  nix-homebrew = {
	   enable = true;
	   user = "themos";
	 };
	}
      ];
      specialArgs = { inherit inputs; };
    };
    darwinPackages = self.darwinConfigurations."wh34tl3y".pkgs;
  };
}

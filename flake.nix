{
	description = "wheatley nix config";

	inputs = {
		# Pin to specific commits for reproducibility
		nixpkgs-master.url = "github:NixOS/nixpkgs/10e60bc678024e12bf5d5611f0ca86cca831bce0";
		nixpkgs-stable.url = "github:NixOS/nixpkgs/dceee767199096d695acefbfd31adc04381e1cb2";
		nixpkgs-unstable.url = "github:NixOS/nixpkgs/472908faa934435cf781ae8fac77291af3d137d3";

		darwin = {
			url = "github:nix-darwin/nix-darwin/e04a388232d9a6ba56967ce5b53a8a6f713cdfcf";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};

		home-manager = {
			url = "github:nix-community/home-manager/1fa73bb2cc39e250eb01e511ae6ac83bfbf9f38c";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
		};

		flake-compat = {
			url = "github:edolstra/flake-compat/9100a0f413b0c601e0533d1d94ffd501ce2e7885";
			flake = false;
		};

		flake-utils.url = "github:numtide/flake-utils/11707dc2f618dd54ca8739b309ec4fc024de578b";

		prefmanager = {
			url = "github:malob/prefmanager/b9d8e2d2d4d9bcf3e46232c4ad9f6207d23921a0";
			inputs.nixpkgs.follows = "nixpkgs-unstable";
			inputs.flake-compat.follows = "flake-compat";
			inputs.flake-utils.follows = "flake-utils";
		};
	};

	outputs = 
	{
		self,
		darwin,
		home-manager,
		flake-utils,
		...
	}@inputs:
	let
		inherit(self.lib)
			attrValues
			makeOverridable
			mkForce
			optionalAttrs
			singleton
			;

		homeStateVersion = "25.11";

		nixpkgsDefaults = {
			config = {
				allowUnfree = true;
			};
			overlays = 
				attrValues self.overlays
				++ [ inputs.prefmanager.overlays.prefmanager ]
				++ singleton (
					final: prev:
					(optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
					})
				);
		};

		primaryUserDefaults = {
			username = "themos";
			fullName = "Themos Papatheofanous";
			email = "themos360@gmail.com";
			nixConfigDirectory = "/Users/themos/nix";
		};

	in
	{
		lib = inputs.nixpkgs-unstable.lib.extend (
		_: _: {
			mkDarwinSystem = import ./lib/mkDarwinSystem.nix inputs;
			lsnix = import ./lib/lsnix.nix;
		}
		);

		
      		overlays = {
        		pkgs-master = _: prev: {
          			pkgs-master = import inputs.nixpkgs-master {
            				inherit (prev.stdenv) system;
            				inherit (nixpkgsDefaults) config;
          			};
        		};
        		pkgs-stable = _: prev: {
          			pkgs-stable = import inputs.nixpkgs-stable {
            				inherit (prev.stdenv) system;
            				inherit (nixpkgsDefaults) config;
          			};
        		};

        		pkgs-unstable = _: prev: {
          			pkgs-unstable = import inputs.nixpkgs-unstable {
            				inherit (prev.stdenv) system;
            				inherit (nixpkgsDefaults) config;
          			};
        		};

        		apple-silicon =
          			_: prev:
          			optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
            			# Add access to x86 packages system is running Apple Silicon
            				pkgs-x86 = import inputs.nixpkgs-unstable {
              					system = "x86_64-darwin";
              					inherit (nixpkgsDefaults) config;
            				};
          			};

        			tweaks = final: _: {
          				# Add temporary overrides here
        			};
      			};
      			# }}}

      # Modules -------------------------------------------------------------------------------- {{{

      			darwinModules = {
        			# My configurations
        			themos-bootstrap = import ./darwin/bootstrap.nix;
        			themos-defaults = import ./darwin/defaults.nix;
        			themos-general = import ./darwin/general.nix;
        			themos-homebrew = import ./darwin/homebrew.nix;

        			# Modules I've created
        			users-primaryUser = import ./modules/darwin/users.nix;
      			};

			homeManagerModules = {
				themos-colors = import ./home/colors.nix;
				themos-config-files = import ./home/config-files.nix;
				themos-fish = import ./home/fish.nix;
				themos-git = import ./home/git.nix;
				themos-ghostty = import ./home/ghostty.nix;
				themos-packages = import ./home/packages.nix;
				themos-starship = import ./home/starship.nix;
				themos-starship-symbols = import ./home/starship-symbols.nix;

				colors = import ./modules/home/colors;
        			home-user-info =
          				{ lib, ... }:
          				{
            					options.home.user-info =
              						(self.darwinModules.users-primaryUser {
                						inherit lib;
              					}).options.users.primaryUser;
          				};
			};

 # System configurations ------------------------------------------------------------------ {{{

      			darwinConfigurations = {
        			# Minimal macOS configurations to bootstrap systems
        			bootstrap-x86 = makeOverridable darwin.lib.darwinSystem {
          				system = "x86_64-darwin";
          				modules = [
            					./darwin/bootstrap.nix
            					{ nixpkgs = nixpkgsDefaults; }
          				];
        			};
        			bootstrap-arm = self.darwinConfigurations.bootstrap-x86.override {
          				system = "aarch64-darwin";
        			};

        			# My Apple Silicon macOS laptop config
        			wh34tl3y = makeOverridable self.lib.mkDarwinSystem (
          				primaryUserDefaults
          				// {
            					modules =
              						attrValues self.darwinModules
              						++ singleton {
                						nixpkgs = nixpkgsDefaults;
                						networking.computerName = "wh34tl3y";
                						networking.hostName = "wh34tl3y";
                						networking.knownNetworkServices = [
                  							"Wi-Fi"
                  							"USB 10/100/1000 LAN"
                						];
                						nix.registry.my.flake = inputs.self;
              						};
            						extraModules = singleton {
              							nix.linux-builder = {
                							enable = true;
                							ephemeral = true;
                							maxJobs = 8;
                							config.virtualisation = {
                  								cores = 8;
                  								darwin-builder.memorySize = 16 * 1024;
                							};
              							};
            						};
            						inherit homeStateVersion;
            						homeModules = attrValues self.homeManagerModules;
          				}
        			);
			};
		};
}


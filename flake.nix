{
  description = "wheatley nix config";
  inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    # Note: The stable branch name changes over time (e.g., nixos-24.05, nixos-24.11).
    # Update this to the current stable branch you want to follow.
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    flake-compat = {
      url = "github:edolstra/flake-compat/master";
      flake = false;
    };

    flake-utils.url = "github:numtide/flake-utils/main";

    prefmanager = {
      url = "github:malob/prefmanager/master";
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
      inherit (self.lib)
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
            (optionalAttrs (prev.stdenv.hostPlatform.system == "aarch64-darwin") {
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
            system = prev.stdenv.hostPlatform.system;
            inherit (nixpkgsDefaults) config;
          };
        };
        pkgs-stable = _: prev: {
          pkgs-stable = import inputs.nixpkgs-stable {
            system = prev.stdenv.hostPlatform.system;
            inherit (nixpkgsDefaults) config;
          };
        };

        pkgs-unstable = _: prev: {
          pkgs-unstable = import inputs.nixpkgs-unstable {
            system = prev.stdenv.hostPlatform.system;
            inherit (nixpkgsDefaults) config;
          };
        };

        apple-silicon =
          _: prev:
          optionalAttrs (prev.stdenv.hostPlatform.system == "aarch64-darwin") {
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

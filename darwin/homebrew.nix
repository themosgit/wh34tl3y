{ config, lib, ... }:

let
  inherit (lib) mkIf; caskPresent = cask: lib.any (x: x.name == cask) config.homebrew.casks;
in

{
  homebrew.enable = true;
  homebrew.onActivation.autoUpdate = true;
  homebrew.onActivation.cleanup = "zap";
  homebrew.global.brewfile = true;

  homebrew.taps = [
    "nrlquaker/createzap"
  ];

  # Prefer installing application from the Mac App Store
  homebrew.masApps = {
    Xcode = 497799835;
    PowerPoint = 462062816;
  };

  # If an app isn't available in the Mac App Store, or the version in the App Store has
  # limitiations, e.g., Transmit, install the Homebrew Cask.
  homebrew.casks = [
    "steam"
    "firefox"
    "ghostty"
    "keepassxc"
    "spotify"
    "libreoffice"
    "thunderbird"
    "wireshark-app"
    "transmission"
    "caffeine"
    "macs-fan-control"
    "skim"
    "mullvad-vpn"
  ];

  # Hack: https://github.com/ghostty-org/ghostty/discussions/2832
  environment.variables.XDG_DATA_DIRS = mkIf (caskPresent "ghostty") [
    "$GHOSTTY_SHELL_INTEGRATION_XDG_DIR"
  ];

  # For cli packages that aren't currently available for macOS in `nixpkgs`. Packages should be
  # installed in `../home/packages.nix` whenever possible.
  homebrew.brews = [
    "composer"
    "luarocks"
    "octave"
  ];
}

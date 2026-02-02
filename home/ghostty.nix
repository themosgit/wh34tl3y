{ lib, pkgs, ... }:

let
  inherit (lib.generators) toKeyValue mkKeyValueDefault;

  mkThemeConfig = toKeyValue {
    mkKeyValue = mkKeyValueDefault { } " = ";
    listsAsDuplicateKeys = true;
  };
in

{
  xdg.configFile."ghostty/config".text = toKeyValue { mkKeyValue = mkKeyValueDefault { } " = "; } {
    font-family = "JetBrains Mono";
    font-size = 14;
    font-thicken = false;
    cursor-invert-fg-bg = true;
    cursor-style = "bar";

    background-opacity = 0.95;
    background-blur = true;

    shell-integration = "fish";

    macos-icon = "xray";
    theme = "rose pine";
    window-theme = "system";
    window-colorspace = "display-p3";
    # background-blur-radius = 20;

    auto-update = "download";
  };
}

# nix-darwin-config


First install upstream nix from the determinate installer chοosing no when asked if you want to install determinate nix.
This config uses flakes and home manager. Homebrew is used to install mac appstore apps and gui apps that we want to show up when searching spotlight.


after nix has been downloaded run 
```sh
nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"
```
then 
```sh
nix run nix-darwin --extra-experimental-features "nix command flakes" --switch --flake ~/nix
```

and rebuilds with `darwin-rebuild switch --flake ~/nix`


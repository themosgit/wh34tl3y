# nix-darwin-config


first install upstream nix from the determinate installer chosing no when asked if you want to install determinate nix 


after nix has been downloaded run 
`nix flake init -t nix-darwin --extra-experimental-features "nix-command flakes"`
then
`nix run nix-darwin --extra-experimental-features "nix command flakes" --switch --flake ~/nix`

and rebuilds with `darwin-rebuild switch --flake ~/nix`


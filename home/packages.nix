{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib) attrValues mkIf elem;

  mkOpRunAliases =
    cmds: lib.genAttrs cmds (cmd: mkIf (elem pkgs.${cmd} config.home.packages) "op run -- ${cmd}");
in

{
  # Bat, a substitute for cat.
  # https://github.com/sharkdp/bat
  # https://nix-community.github.io/home-manager/options.html#opt-programs.bat.enable
  programs.bat.enable = true;
  programs.bat.config = {
    style = "plain";
  };

  # Btop, a fancy version of `top`.
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.btop.enable
  programs.btop.enable = true;

  # Eza, a modern, maintained replacement for ls, written in rust
  # https://eza.rocks
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.eza.enable
  programs.eza.enable = true;
  programs.eza.git = true;
  programs.eza.icons = "auto";
  programs.eza.extraOptions = [ "--group-directories-first" ];
  home.sessionVariables.EZA_COLORS = "xx=0"; # https://github.com/eza-community/eza/issues/994
  home.sessionVariables.EZA_ICON_SPACING = 2;

  #SSH
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        # The old defaults are now set explicitly here.
        # You can add or remove any options you want.
        controlMaster = "auto";
        controlPersist = "1m";
        controlPath = "~/.ssh/master-%r@%n:%p";
      };
      "glados" = {
        hostname = "192.168.178.203";
        user = "themos";
        port = 22;
      };
    };
  };
  # Zoxide, a faster way to navigate the filesystem   # Zoxide, a faster way to navigate the filesystem
  # https://github.com/ajeetdsouza/zoxide
  # https://nix-community.github.io/home-manager/options.html#opt-programs.zoxide.enable
  programs.zoxide.enable = true;

  # Zsh
  # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zsh.enable
  programs.zsh.enable = true;
  programs.zsh.dotDir = "${config.xdg.configHome}/zsh";
  programs.zsh.history.path = "${config.xdg.stateHome}/zsh_history";
  home.packages = attrValues (
    {
      # Some basics
      inherit (pkgs)
        nmap
        killall
        doctl
        glow # view .md in terminal
        lld_20
        neofetch
        docker
        tmux
        gdb
        tree
        neovim
        julia-lts
        tree-sitter # neovim parser
        bandwhich # display current network utilization by process
        coreutils
        curl
        du-dust # fancy version of `du`
        eza # fancy version of `ls`
        fd # fancy version of `find`
        hyperfine # benchmarking tool
        mosh # wrapper for `ssh` thats better and not dropping connections
        ripgrep # better version of `grep`
        tealdeer # rust implementation of `tldr`
        unrar # extract RAR archives
        upterm # secure terminal sharing
        wget
        xz # extract XZ archives
        ;

      # Useful nix related tools
      inherit (pkgs)
        comma # run software from without installing it
        nix-output-monitor # get additional information while building packages
        nix-tree # interactively browse dependency graphs of Nix derivations
        nix-update # swiss-knife for updating nix packages
        nixpkgs-review # review pull-requests on nixpkgs
        statix # lints and suggestions for the Nix programming language
        nixfmt-rfc-style # nix formatter
        ;

    }
    // lib.optionalAttrs pkgs.stdenv.isDarwin {
      inherit (pkgs)
        m-cli # useful macOS CLI commands
        prefmanager # tool for working with macOS defaults
        swift-format
        swiftlint
        ;
    }
  );
}

{ config, ... }:

{
  # Git
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.git.enable
  # Aliases config in ./configs/git-aliases.nix
  programs.git.enable = true;

  programs.git.settings = {
    diff.colorMoved = "default";
    pull.rebase = true;
    user.name = "themosgit";
	user.email = "themos360@gmail.com";
	init.defaultBranch = "main";
	push.autoSetupRemote = true;
	url = {
	  "git@github.com:" = {
		insteadOf = "https://github.com/";
	  };
	};
  };

  programs.git.signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
  };

  programs.git.settings.gpg.format = "ssh";

  services.ssh-agent.enable = true;

  programs.git.ignores = [
    "*~"
    ".DS_Store"
  ];

  # Enhanced diffs
  # programs.git.delta.enable = true;
  programs.difftastic.enable = true;
  programs.difftastic.git.enable = true;
  programs.difftastic.options.display = "inline";

  # GitHub CLI
  # https://rycee.gitlab.io/home-manager/options.html#opt-programs.gh.enable
  # Aliases config in ./gh-aliases.nix
  programs.gh.enable = true;
  programs.gh.settings.version = 1;
  programs.gh.settings.git_protocol = "ssh";
}

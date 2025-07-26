{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Add a path to the nixpath for config search
  #   nix.nixPath = [
  #     "nixpkgs=${pkgs.path}"
  #     "nixos-config=/home/hcooh/nixos-config/configuration.nix"
  #   ];

  imports = [
    ./sops.nix # allow sops secrets
  ];

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  environment.systemPackages = with pkgs; [

    # Utilities
    git
    wget
    oh-my-zsh
    which
    zip
    unzip
    xz
    p7zip
    nix-tree

    # Fonts
    powerline-fonts

  ];

  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.theme = "af-magic";
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "ls -l";
      nixupdate = "sudo nixos-rebuild switch";
      nixedit = "sudo nano /etc/nixos/configuration.nix";
    };
    histSize = 5000;
  };
  users.defaultUserShell = pkgs.zsh; # set as default shell

  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };

  # Optimize storage
  # You can also manually optimize the store via:
  #    nix-store --optimise
  # Refer to the following link for more details:
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  sops.templates.nix_access_tokens.content = ''
    extra-access-tokens = github.com=${config.sops.placeholder.github_token_read_secrets_repo}
  '';
  #     sops.templates.nix_access_tokens.owner = config.users.users.${username}.name;
  nix.extraOptions = ''
    !include ${config.sops.templates.nix_access_tokens.path}
  '';

}

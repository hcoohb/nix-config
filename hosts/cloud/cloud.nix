# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../users/hcooh/hcooh.nix # add each users
    ./hardware-configuration.nix # Include the results of the hardware scan.
    ../hosts.nix # common nixos to all hosts
    ./disko.nix
    "${inputs.mysecrets}/cloud/traefik/traefik.nix" # import traefik config from secrets for privacy
  ];

  environment.systemPackages = with pkgs; [
    glances
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  boot.loader.grub.configurationLimit = 10;
  boot.loader.grub.useOSProber = true;
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.efiInstallAsRemovable = true;

  networking.hostName = "cloud"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "Australia/Brisbane";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # enable tailscale
  services.tailscale = {
    enable = true;
    authKeyFile = config.sops.secrets.cloud_tailscale_auth_key.path;
    extraSetFlags = [ "--advertise-exit-node" ];
    useRoutingFeatures = "server";
  };
  sops.secrets.cloudnix_tailscale_auth_key = { };

  services.glances = {
    enable = true;
    extraArgs = [
      "--webserver"
      "--disable-history"
    ];
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.openFirewall = false; # do not open firewall for non tailscale
  services.openssh.settings.PermitRootLogin = "no";
  services.openssh.extraConfig = ''
    LoginGracetime 2m
    MaxAuthTries 4
  '';
  /*
    virtualisation.docker.enable = true;
    # Configure Docker daemon to automatically prune in configuration.nix
    virtualisation.docker.autoPrune.enable = true;
    virtualisation.docker.autoPrune.dates = "daily";
  */

  # nix.settings.trusted-public-keys = [
  #   "hcooh-nucnix:AAAAC3NzaC1lZDI1NTE5AAAAIJQBT4vB7oPLaot2M420iNeIgeJqHX4weW46twSlD2yf"
  # ]:

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

{ config, pkgs, ... }:

{

  ##################################################################################################################
  #
  # NixOS Configuration
  #
  ##################################################################################################################

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.hcooh = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  ##################################################################################################################
  #
  # Home-Manager Configuration
  #
  ##################################################################################################################

  home-manager.users.hcooh = {

    imports = [
      ../home/common.nix
    ];


    # Packages that should be installed to the user profile.
    home.packages = with pkgs; [
      tree
    ];

    # basic configuration of git
    programs.git = {
      enable = true;
      userName = "hcoohb";
      userEmail = "hcoohb@gmail.com";
    };


    # This value determines the home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update home Manager without changing this value. See
    # the home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "25.05";
  };



}

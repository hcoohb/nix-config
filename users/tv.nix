{ config, pkgs, ... }:

let
  username = "tv";
in
{

  ##################################################################################################################
  #
  # NixOS Configuration
  #
  ##################################################################################################################

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    isNormalUser = true;
    initialPassword = "abc123";
    extraGroups = [ "networkmanager" ]; # Enable ‘sudo’ for the user.
  };

  ##################################################################################################################
  #
  # Home-Manager Configuration
  #
  ##################################################################################################################

  home-manager.users.${username} = {

    imports = [
      ../home/common.nix
    ];



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

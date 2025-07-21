{ config, pkgs, ... }:

let
  username = "hcooh";
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
    uid = 1000;
    group = "users";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  ##################################################################################################################
  #
  # Home-Manager Configuration
  #
  ##################################################################################################################

  home-manager.users.${username} = {

    imports = [
      ../../home/home.nix
    ];


    # Packages that should be installed to the user profile.
    home.packages = with pkgs; [
      tree
      tigervnc
    ];

    # basic configuration of git
    programs.git = {
      enable = true;
      userName = "hcoohb";
      userEmail = "hcoohb@gmail.com";
    };


#     home.file = {
#       test5.text = "${config.sops.secrets.new_val.key}";
#       test6.text = "${config.sops.secrets.hello.key}";
#     };

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


   ##### SECRETS
    sops.secrets = {
      new_val={
        owner = config.users.users.${username}.name;
        inherit (config.users.users.${username}) group;
      };
      hello={
        owner = config.users.users.${username}.name;
        inherit (config.users.users.${username}) group;
      };
    };




}

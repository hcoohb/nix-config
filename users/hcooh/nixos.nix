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
#     packages = with pkgs; [
#       tree
#     ];
  };
}

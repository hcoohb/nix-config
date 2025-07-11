{ config, pkgs, username, ... }:

{

  imports = [
    ../../home/common.nix
  ];



  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    tree
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "hcoohb";
    userEmail = "hcoohb@gmail.com";
  };


}

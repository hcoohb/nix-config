{ config, lib, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.displayManager.defaultSession = "none+i3";
  security.pam.services.i3lock.enable = true;

}

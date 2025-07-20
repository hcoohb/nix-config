{ config, pkgs, lib, ... }:
{



  services.xserver = {
    enable = true;
    windowManager.openbox.enable = true;
  };

}

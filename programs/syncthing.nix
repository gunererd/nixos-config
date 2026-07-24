{ config, pkgs, ... }:

{
  services.syncthing = {
    enable = true;
    user = "hippo";
    group = "users";
    dataDir = "/home/hippo";
    configDir = "/home/hippo/.config/syncthing";
    openDefaultPorts = true;
    # Manage devices/folders from the web GUI; don't wipe them on restart.
    overrideDevices = false;
    overrideFolders = false;
  };
}

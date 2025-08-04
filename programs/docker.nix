{ config, pkgs, ... }:

{
  # Enable Docker
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  # Add docker-compose to system packages
  environment.systemPackages = with pkgs; [
    docker-compose
  ];

  # Add user to docker group (will need to re-login after rebuild)
  users.users.hippo.extraGroups = [ "docker" ];
}
{
  description = "My NixOS configuration with flakes";

  inputs = {
    # NixOS official package source, using the unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {

      stinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/stinkpad/configuration.nix
          ./machines/stinkpad/hardware-configuration.nix

          { nixpkgs.config.allowUnfree = true; }
          
        ];
      };
    };
  };
} 
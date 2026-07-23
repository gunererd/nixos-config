{
  description = "My NixOS configuration with flakes";

  inputs = {
    # NixOS official package source, using the unstable branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {

      stinkpad = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/stinkpad/configuration.nix
          ./machines/stinkpad/hardware-configuration.nix

          { 
            nixpkgs.config.allowUnfree = true;
            # TODO: Check for secure builds of beekeeper-studio with newer Electron
            nixpkgs.config.permittedInsecurePackages = [
              "beekeeper-studio-5.2.12"
            ];
          }
          
        ];
      };

      tiny = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/tiny/configuration.nix
          ./machines/tiny/hardware-configuration.nix

          { nixpkgs.config.allowUnfree = true; }
          
        ];
      };

      vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./machines/vm/configuration.nix
          ./machines/vm/hardware-configuration.nix

          { nixpkgs.config.allowUnfree = true; }
          
        ];
      };

    };


  };
} 
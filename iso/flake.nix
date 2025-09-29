# flake.nix
{
  description = "Minimal NixOS ISO with Disko";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }: {
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux"; # Adjust for your architecture
      modules = [
        # Import the installation CD module for basic ISO functionality
        #"${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        #"${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
        <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
        disko.nixosModules.default
        # Your custom configuration for the ISO environment
        ./configuration.nix
      ];
#       specialArgs = {inherit inputs outputs;};
    };
  };
}

# build iso by:
# nix build .#nixosConfigurations.iso.config.system.build.isoImage --extra-experimental-features 'nix-command flakes'

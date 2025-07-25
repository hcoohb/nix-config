{
  description = "NixOS configuration";

  inputs = {
    # NixOS official package source, using the nixos-25.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # home-manager, used for managing user configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";

    };
    disko = {
      url = "github:nix-community/disko/latest";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Add the private repo that contains all secrets:
    mysecrets = {
      url = "github:hcoohb/nix-secrets";
#       url = "git+ssh://git@github.com/hcoohb/nix-secrets.git?ref=main&shallow=1";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, disko, ... }@inputs:
  let
    shared-modules = [
      # make home-manager as a module of nixos
      # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
      }
    ];
    shared-specialArgs = { inherit inputs disko; };
  in
  {
    nixosConfigurations =
    {
    nucnix =
      nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = shared-modules ++ [ ./hosts/nuc/nuc.nix ];
      specialArgs = shared-specialArgs;
    };
    cloudnix =
      nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = shared-modules ++ [ ./hosts/cloud/cloud.nix ];
      specialArgs = shared-specialArgs;
    };

    asus360 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = shared-modules;
    };

    };
  };
}

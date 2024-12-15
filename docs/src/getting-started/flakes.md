# Flakes

Flakes are the preferred way to use `cosmic-manager`, offering a modern and reproducible way to manage your COSMIC desktop.

If you have Flakes enabled, this will be the easiest and most flexible method to get started.

## Adding `cosmic-manager` as an Input

First, add `cosmic-manager` to the inputs in your `flake.nix` file. Here’s an example:

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    cosmic-manager = {
      url = "github:HeitorAugustoLN/cosmic-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, cosmic-manager, ... }: {
    # Outputs will depend on your setup (home-manager as NixOS module or standalone home-manager).
  };
}
```

## Using `cosmic-manager` with a `home-manager` as NixOS module installation

If you’re using `home-manager` as a NixOS module, your `flake.nix` file might look like this:

```nix
{
  outputs = { nixpkgs, home-manager, cosmic-manager, ... }: {
    nixosConfigurations.my-computer = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.users.cosmic-user = {
            imports = [
              ./home.nix
              cosmic-manager.homeManagerModules.cosmic-manager
            ];
          };
        }
      ];
    };
  };
}
```

## Using `cosmic-manager` with a standalone `home-manager` installation

If you’re using `home-manager` as a standalone tool, your `flake.nix` file might look like this:

```nix
{
  outputs = { nixpkgs, home-manager, cosmic-manager, ... }: {
    homeConfigurations."cosmic-user@my-computer" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ./home.nix
        cosmic-manager.homeManagerModules.cosmic-manager
      ];
    };
  };
}
```

Follow this guide, and you’ll have `cosmic-manager` up and running with Flakes in no time!

# Stable Nix

When using stable Nix, you have several options to install `cosmic-manager` based on your preferences and setup. Choose one of the methods below to get started.

## Option 1: Using `npins`

[`npins`](https://github.com/andir/npins) simplifies the process of ["pinning"](https://nix.dev/tutorials/first-steps/towards-reproducibility-pinning-nixpkgs) external dependencies for your configuration.

### Steps:

1. Ensure you have followed [the `npins` getting started guide](https://github.com/andir/npins#getting-started).
2. Add `cosmic-manager` to your configuration:

```sh
npins add --name cosmic-manager github HeitorAugustoLN cosmic-manager
```

3. Update your Nix configuration:

**With `home-manager` integrated into NixOS:**

```nix
let
  sources = import ./npins;
in
{
  home-manager.users.cosmic-user = {
    imports = [
      (sources.cosmic-manager + "/modules")
    ];

    wayland.desktopManager.cosmic.enable = true;
  };
}
```

**With standalone `home-manager`:**

```nix
let
  sources = import ./npins.nix;
in
{
  imports = [
    (sources.cosmic-manager + "/modules")
  ];

  home.username = "cosmic-user";
  programs.home-manager.enable = true;

  wayland.desktopManager.cosmic.enable = true;
}
```

## Option 2: Using Channels

[Nix channels](https://nixos.org/manual/nix/stable/command-ref/nix-channel.html) offer a simple way to download, update, and use `cosmic-manager` modules. However, this approach sacrifices reproducibility across different machines.

### Steps:

1. Add the `cosmic-manager` channel:

```sh
sudo nix-channel --add https://github.com/HeitorAugustoLN/cosmic-manager/archive/main.tar.gz cosmic-manager
sudo nix-channel --update
```

2. Update your Nix configuration:

**With `home-manager` integrated into NixOS:**

```nix
{
  home-manager.users.cosmic-user = {
    imports = [
      <cosmic-manager/modules>
    ];

    wayland.desktopManager.cosmic.enable = true;
  };
}
```

**With standalone `home-manager`:**

```nix
{
  imports = [
    <cosmic-manager/modules>
  ];

  home.username = "cosmic-user";
  programs.home-manager.enable = true;

  wayland.desktopManager.cosmic.enable = true;
}
```

## Which Option Should I Choose?

- **Use `npins`**: If you want better reproducibility and a cleaner way to manage external dependencies.
- **Use Channels**: If you prefer a simpler setup and are okay with sacrificing strict reproducibility.

With either method, you’re set to manage your COSMIC desktop declaratively!

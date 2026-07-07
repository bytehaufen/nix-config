<!-- markdownlint-disable MD033 MD013 -->

<h1 align="center">❄️Bytehaufens nix-config❄️</h1>

> [!warning]
> This repository is currently under heavy development. Also this README is unfinished and needs to
> be refactored. So do not use this! 🚧
>
> Currently I am migrating from arch linux to NixOS. So this repository will be updated frequently.
> Many things have to be refactored, are buggy, broken, incomplete, whatever. If you have any
> questions or suggestions, feel free to open an issue.

This repository contains my personal NixOS and Home Manager configuration files.

I use [Nix flakes](https://nixos.wiki/wiki/Flakes) for managing the configuration.

## Structure

TBD

## Secrets

TBD

## Applications and tooling I use

|                      | Tool                                                                |
| -------------------- | ------------------------------------------------------------------- |
| Window Manager       | [Niri](https://niri-wm.github.io/niri/index.html)                   |
| Terminal Emulator    | [Kitty](https://sw.kovidgoyal.net/kitty/)                           |
| Shell                | [Zsh](https://www.zsh.org/)                                         |
| PDF Viewer           | [Zathura](https://pwmt.org/projects/zathura/)                       |
| Editor               | [Neovim](https://neovim.io/) \| [Eclipse](https://www.eclipse.org/) |
| Terminal Multiplexer | [Tmux](https://github.com/tmux/tmux/)                               |
| File Manager         | [Yazi](https://github.com/sxyazi/yazi) \| Nautilus                  |

## Deploy this flake via nix-anywhere to a VM

```sh
nix run 'nixpkgs#nixos-anywhere' -- --flake .#vm1 --generate-hardware-config nixos-generate-config ./hardware-configuration.nix nixos@127.0.0.1 -p 22220
```

## Install NixOS from this repo to a VM

> [!error]
> This way does not work with agenix. Use the nix-anywhere way instead.

```sh
# Enter shell with git, just and vim available
nix --extra-experimental-features 'nix-command flakes' \
  shell 'nixpkgs#git' 'nixpkgs#just' 'nixpkgs#vim'

# Generate NixOS configuration to /tmp/config
nixos-generate-config --root /tmp/config --no-filesystems

cd /tmp

# Clone this repository to /tmp/nix-config
git clone https://github.com/bytehaufen/nix-config.git

# Remove the old hardware-configuration.nix
rm nix-config/hosts/vm1/hardware-configuration.nix

# Move the generated hardware-configuration.nix to the correct location
mv config/etc/nixos/hardware-configuration.nix nix-config/hosts/vm1/

# Prepare the disks with disko
sudo nix --experimental-features 'nix-command flakes'        \
       run github:nix-community/disko/latest -- --mode disko \
       --flake './nix-config#vm1' --show-trace --verbose

# Install NixOS to the prepared disks
sudo nixos-install -v --show-trace --no-root-passwd --root /mnt \
       --flake './nix-config#vm1'

# Enter into the installed system, check password & users
# `su rico` => `sudo -i` => enter password => successfully login
nixos-enter

# Move nix-config to /home/rico
mv nix-config /mnt/home/rico
```

<!-- Deprecated start --->

## Build the Home Manager configuration

- Building and activating via direct Nix command:

  ```shell
  # Build configuration
  nix build ".#homeConfigurations.rico@arch.activationPackage"

  # Activate configuration
  ./result/activate
  ```

- Or using Home Manager's built-in command:

  ```shell
  home-manager switch --flake ".#rico@arch"
  ```

## Shorthands

For frequently used commands like `home-manager switch ...`, utilize _just_ for simplification. To
see all available commands with just, execute:

```shell
just
```

<!-- Deprecated end --->

## Special Thanks

To ryan4yin for his great book [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world), that
helped me a lot to get started with NixOS and flakes and to flatten the steep learning curve.

To Folke Lemaitre for his awesome [neovim](https://github.com/neovim/neovim) plugin manager
[💤 lazy.nvim](https://github.com/folke/lazy.nvim) and the corresponding neovim setup
[LazyVim](https://github.com/folke/lazy.nvim)

Dotfiles that inspired me:

- [ryan4yin](https://github.com/ryan4yin/nix-config)
- [Misterio77](https://github.com/Misterio77/nix-config)
- [fufexan](https://github.com/fufexan/dotfiles)

and many many others ... ❤️

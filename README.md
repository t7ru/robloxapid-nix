# RobloxAPID Nix Flake

Nix flake providing a Nix package and NixOS module for the [RobloxAPID](https://github.com/paradoxum-wikis/RobloxAPID) daemon.

## Usage (NixOS)

**1. Add as input:**

```nix
inputs.robloxapid-nix.url = "github:t7ru/robloxapid-nix";
```

**2. Add overlay and module, then enable service:**

```nix
# in your flake.nix modules list
{ nixpkgs.overlays = [ robloxapid-nix.overlays.default ]; }
robloxapid-nix.nixosModules.robloxapid

# in configuration.nix
services.robloxapid.enable = true;
services.robloxapid.configFile = "/etc/robloxapid/config.json";
```

**3. Build/reload:**

```sh
sudo nixos-rebuild switch --flake /etc/nixos#your-hostname
```

## Package only

```sh
nix run github:t7ru/robloxapid-nix#robloxapid
```

## Notes

- Default config path is `/etc/robloxapid/config.json`.
- Please for the love of god use sops-nix or agenix for secrets.
- This flake is under [MIT](LICENSE), but RobloxAPID is under [AGPLv3](https://github.com/paradoxum-wikis/RobloxAPID/blob/main/LICENSE).
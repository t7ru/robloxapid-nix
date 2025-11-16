{
  description = "RobloxAPID packaging and deployment bits";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    robloxapid-src = {
      url = "github:paradoxum-wikis/RobloxAPID";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, robloxapid-src, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
    in
    {
      overlays.default = final: prev: {
        robloxapid = prev.callPackage ./nix/pkgs/robloxapid.nix { src = robloxapid-src; };
      };

      packages = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        {
          robloxapid = pkgs.robloxapid;
          default = pkgs.robloxapid;
        });

      nixosModules.robloxapid = import ./nix/modules/robloxapid-service.nix;

      apps = nixpkgs.lib.genAttrs systems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.default}/bin/robloxapid";
          meta = { description = "Run RobloxAPID daemon"; };
        };
      });

      checks = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
          testConfigJson = ''
          {
            "server": {
              "categoryCheckInterval": "1m",
              "dataRefreshInterval": "30m"
            },
            "wiki": {
              "apiUrl": "https://your-wiki.com/api.php",
              "username": "YourWikiUsername@YourBotName",
              "password": "your_bot_password_here",
              "namespace": "Module"
            },
            "dynamicEndpoints": {
              "categoryPrefix": "robloxapid-queue",
              "apiMap": {
                "badges": "https://badges.roblox.com/v1/badges/%s",
                "users": "https://apis.roblox.com/cloud/v2/users/%s",
                "groups": "https://apis.roblox.com/cloud/v2/groups/%s",
                "universes": "https://apis.roblox.com/cloud/v2/universes/%s",
                "places": "https://apis.roblox.com/cloud/v2/%s",
                "games": "https://games.roblox.com/v1/games?universeIds=%s",
                "favorites": "https://games.roblox.com/v1/games/%s/favorites/count",
                "votes": "https://games.roblox.com/v1/games/%s/votes",
                "virtual-events": "https://apis.roblox.com/virtual-events/v2/universes/%s/experience-events"
              },
              "refreshIntervals": {
                "badges": "30m",
                "about": "168h",
                "users": "1h",
                "groups": "1h",
                "universes": "1h",
                "places": "1h",
                "games": "1h",
                "favorites": "2h",
                "votes": "2h",
                "virtual-events": "3h"
              }
            },
            "openCloud": {
              "apiKey": "YOUR_OPEN_CLOUD_KEY"
            },
            "roblox": {
              "cookie": "YOUR_COOKIE"
            }
          }
          '';
        in
        {
          build = self.packages.${system}.robloxapid;

          vm-test = pkgs.nixosTest {
            name = "robloxapid-test";
            nodes.machine = { pkgs, ... }: {
              imports = [ self.nixosModules.robloxapid ];
              services.robloxapid.enable = true;

              services.robloxapid.configFile = pkgs.writeText "config.json" testConfigJson;
            };

            testScript = ''
start_all()
machine.wait_for_unit("robloxapid.service")
machine.succeed("systemctl status robloxapid.service")
'';
          };
        });
    };
}

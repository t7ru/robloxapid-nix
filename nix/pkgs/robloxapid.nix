{ lib, buildGoModule, src ? ./.. }:
buildGoModule {
  pname = "robloxapid";
  version = "0.0.16";
  inherit src;
  vendorHash = "sha256-FTppGvJ8pY0jB9RK7KVX9SvT1W3cbvA/Efv3Fo0AK2w=";
  doCheck = false;
  ldflags = [ "-s" "-w" ];
  meta = {
    description = "A daemon that bridges the Roblox API to Fandom wikis. (MediaWiki)";
    homepage = "https://github.com/paradoxum-wikis/RobloxAPID";
    license = lib.licenses.agpl3Plus;
    mainProgram = "robloxapid";
  };
}

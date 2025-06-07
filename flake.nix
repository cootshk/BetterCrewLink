{
  description = "Free, open, Among Us Proximity Chat";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    node16_nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, node16_nixpkgs, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        nodepkgs = import node16_nixpkgs { inherit system; };
        pkgs = import nixpkgs { inherit system; };
        buildNode = nodepkgs.callPackage
          "${node16_nixpkgs}/pkgs/development/web/nodejs/nodejs.nix" {
            python = pkgs.python310;
          };
        node16 = buildNode {
          enableNpm = true;
          version = "16.14.2";
          sha256 = "sha256-6SLiFcxo61+U0z6KC2HiyGO3cxzIYAq5VdOCLakP+NE=";
        };
        buildInputs = with pkgs; [
          # nodepkgs.nodejs-16_x
          node16
          nodepkgs.yarn
          python310Full
          python310Packages.pygobject3
          xorg.libX11
          glib
          nss
          nspr
          at-spi2-atk
          xorg.libxcb
          dbus.lib
          gdk-pixbuf
          gtk3
          pango
          cairo
          xorg.libXcomposite
          xorg.libXdamage
          xorg.libXext
          xorg.libXfixes
          xorg.libXrandr
          expat
          libdrm
          libxkbcommon
          libgbm
          alsa-lib
          cups.lib
        ];
      in {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = buildInputs;
            shellHook = ''
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.xorg.libX11.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.glib.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.nss.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.nspr.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.at-spi2-atk.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.xorg.libxcb.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.dbus.lib}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.gdk-pixbuf.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.gtk3.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.pango.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.cairo.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.xorg.libXcomposite.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.xorg.libXdamage.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.xorg.libXext.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.xorg.libXfixes.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.xorg.libXrandr.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.expat.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libdrm.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libxkbcommon.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.libgbm.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.alsa-lib.out}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.cups.lib}/lib
            '';
          };
        };
        packages.default = pkgs.stdenv.mkDerivation {
          name = "better-crew-link";
          src = ./.;
          buildInputs = buildInputs;

          # nativeBuildInputs = with pkgs; [ yarn ];
          installPhase = ''
            yarn install --frozen-lockfile --network-timeout 100000
          '';
        };
      });
}

{
  description = "Free, open, Among Us Proximity Chat";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    node16_nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    electron11_nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils, node16_nixpkgs, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        nodepkgs = import node16_nixpkgs { inherit system; };
        electronpkgs = import inputs.electron11_nixpkgs { inherit system; };
        buildNode = nodepkgs.callPackage
          "${node16_nixpkgs}/pkgs/development/web/nodejs/nodejs.nix" {
            python = pkgs.python310;
          };
        node16 = buildNode {
          enableNpm = true;
          version = "16.14.2";
          sha256 = "sha256-6SLiFcxo61+U0z6KC2HiyGO3cxzIYAq5VdOCLakP+NE=";
        };
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: {
              nodejs = node16;
              electron_11 = electronpkgs.electron_11;
            })
          ];
        };
        buildInputs = with pkgs; [
          # Binaries
          node16
          yarn
          git
          python310Full
          # Packages
          python310Packages.pygobject3
          # Libraries
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
          glibc_multi.dev
          gcc_multi
        ];
      in {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = buildInputs ++ [ pkgs.yarn2nix ];
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
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.glibc_multi.dev}/lib
              export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.gcc_multi.out}/lib
            '';
          };
        };
        packages.default = import ./default.nix {
          inherit pkgs;
          inherit buildInputs;
        };
        packages.old = pkgs.stdenv.mkDerivation {
          version = "3.1.3";
          name = "better-crew-link";
          pname = "better-crew-link";
          yarnOfflineCache = pkgs.fetchYarnDeps {
            yarnLock = ./yarn.lock;
            hash = "sha256-pHkmgrtQDlb2YE7ORpAixMBfx1Qe9NbmXGIVWZiOu/8=";
          };
          src = ./.;
          buildInputs = buildInputs;
          nativeBuildInputs = with pkgs; [
            yarnConfigHook
            yarnBuildHook
            yarnInstallHook
            node16
          ];
          yarnBuildScript = "dist:linux";
          yarnKeepDevDeps = true;
          yarnPreBuild = ''
            mkdir -p $HOME/.node-gyp/${node16.version}
            echo 9 > $HOME/.node-gyp/${node16.version}/installVersion
            ln -sfv ${node16}/include $HOME/.node-gyp/${node16.version}
            export npm_config_nodedir=${node16}
          '';
        };
      });
}

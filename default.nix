{ pkgs ? import <nixpkgs>, ... }@args:
pkgs.callPackage ./release.nix {
  electron = pkgs.electron_11;
  git = pkgs.git;
  buildInputs = args.buildInputs or [ ];
}

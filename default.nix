{ pkgs ? import <nixpkgs>, ... }:
pkgs.callPackage ./release.nix { electron = pkgs.electron_11; }

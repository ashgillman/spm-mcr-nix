{ stdenv
, lib
, autoPatchelfHook
, fetchzip
, coreutils
, gcc48
, mesa_glu
, ncurses
, xorg
, zlib


, cacert
, alsa-lib
, atk
, glib
, glibc
, cairo
, cups
, dbus
, fontconfig
, gdk-pixbuf
, gtk3
, nspr
, nss
, pam
, pango
#, python3
, libselinux
, libsndfile
, glibcLocales
, procps
, unzip
#, gfortran
#, udev
, jre
, libxcrypt
}@inputs:


let
  matlab-version = "R2019b";
  mcr-major = "9.7";
  mcr-majorshort = "97";
  mcr-minor = "9";
  sha256 = "sha256-oc4wsqUfxrYMJtsQVMQgBpxLMuwuMiCa0UFCxAJxDmY=";

in import ./common.nix ({ inherit matlab-version mcr-major mcr-majorshort mcr-minor sha256; } // inputs)

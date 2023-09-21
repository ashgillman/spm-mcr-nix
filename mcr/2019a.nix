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
  matlab-version = "R2019a";
  mcr-major = "9.6";
  mcr-majorshort = "96";
  mcr-minor = "9";
  sha256 = "sha256-1xPLm7zsNZ2Ho+28z7TpBGE9tXJ7o+b/2EJOglpa4i0=";

in import ./common.nix ({ inherit matlab-version mcr-major mcr-majorshort mcr-minor sha256; } // inputs)

{ stdenv
, lib
, autoPatchelfHook
, makeWrapper
, fetchzip
, matlab-runtime
, gcc48

, zlib
, libxcrypt
, pam
}:

let
  spm-major = "8";
  spm-revision = "6313";
  sha256 = "sha256-4EECXEz1BDC+kLGexL7NS969xW5LOS83gYOp4Ub7sME=";

in import ./common.nix { inherit spm-major spm-revision sha256 stdenv lib autoPatchelfHook makeWrapper fetchzip matlab-runtime gcc48 zlib libxcrypt pam; }

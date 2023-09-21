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
  spm-major = "12";
  spm-revision = "7771";
  sha256 = "sha256-11IhxwyADIizqUlD32d93tmWcT1X1W1WiLUABCMUkoU=";

in import ./common.nix { inherit spm-major spm-revision sha256 stdenv lib autoPatchelfHook makeWrapper fetchzip matlab-runtime gcc48 zlib libxcrypt pam; }

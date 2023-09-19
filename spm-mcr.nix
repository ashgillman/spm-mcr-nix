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
  #matlab-version = "R2019b";
  spm-revision = "7771";
  mcrLibPath = lib.concatStringsSep ":" [
    "${matlab-runtime}/runtime/glnxa64"
    "${matlab-runtime}/bin/glnxa64"
    "${matlab-runtime}/sys/os/glnxa64"
    "${matlab-runtime}/extern/bin/glnxa64"
  ];
in stdenv.mkDerivation {
  inherit mcrLibPath;
  inherit (matlab-runtime) libPath;

  pname = "spm";
  version = "12.${spm-revision}";

  src = fetchzip {
    url = "https://www.fil.ion.ucl.ac.uk/spm/download/restricted/utopia/spm12/spm12_r${spm-revision}_Linux_${matlab-runtime.matlab-version}.zip";
    sha256 = "sha256-11IhxwyADIizqUlD32d93tmWcT1X1W1WiLUABCMUkoU=";
    #stripRoot = false;
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  propagatedBuildInputs = [
    matlab-runtime
  ];

  dontConfigure = true;

  buildPhase = ''
    # For some reason, this /only/ works if most lib paths are rpath'ed, but MATLAB lib paths are LD_LIBRARY_PATH'ed
    # We need to run spm12 binary to unpack the .ctf file.
    # so we patch early

    PATCH_FILES=(
        spm12
    )

    for f in ''${PATCH_FILES[*]}; do
        #chmod u+w $f
        patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${matlab-runtime.libPath}:$(patchelf --print-rpath $f)"\
          --force-rpath $f
    done

    LD_LIBRARY_PATH="${mcrLibPath}" ./spm12 || true
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv * $out/bin/
    chmod ugo+x $out/bin/spm12
  '';

  fixupPhase = ''
    REPLACE_FILES=(
        $out/bin/spm12
        # $out/bin/run_spm12.sh
    )

    for f in ''${REPLACE_FILES[*]}; do
        # substituteInPlace $f\
        #     --replace /bin/pwd $(type -P pwd)\
        #     --replace /bin/echo $(type -P echo)
        wrapProgram $f --set MATLAB_ARCH glnxa64 --set LD_LIBRARY_PATH ${mcrLibPath}
    done

    # The binary kinda breaks and looks for spm.ctf in .ctf... Let it be.
    ln -s $out/bin/spm12.ctf $out/bin/.ctf

    # Might be necessary for some libraries? Leaving here for reference.
    # # Set the correct path to gcc
    # CC_FILES=(
    #     $out/bin/mbuildopts.sh
    #     $out/bin/mexopts.sh
    # )
    # for f in ''${CC_FILES[*]}; do
    #     substituteInPlace $f\
    #         --replace "CC='gcc'" "CC='${gcc48}/bin/gcc'"
    # done
    set +x
  '';
}

{ spm-major
, spm-revision
, sha256

, stdenv
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
  spm-short = "spm${spm-major}";
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
  version = "${spm-major}.${spm-revision}";

  src = fetchzip {
    url = "https://www.fil.ion.ucl.ac.uk/spm/download/restricted/utopia/spm${spm-major}/spm${spm-major}_r${spm-revision}_Linux_${matlab-runtime.matlab-version}.zip";
    inherit sha256;
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
    # We need to run spm binary to unpack the .ctf file.
    # so we patch early

    PATCH_FILES=(
        ${spm-short}
    )

    for f in ''${PATCH_FILES[*]}; do
        #chmod u+w $f
        patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "${matlab-runtime.libPath}:$(patchelf --print-rpath $f)"\
          --force-rpath $f
    done

    LD_LIBRARY_PATH="${mcrLibPath}" ./${spm-short} || true
  '';

  installPhase = ''
    mkdir -p $out/bin
    mv * $out/bin/
    chmod ugo+x $out/bin/${spm-short}
    ln -s ./${spm-short} $out/bin/spm
  '';

  fixupPhase = ''
    REPLACE_FILES=(
        $out/bin/${spm-short}
        # $out/bin/run_${spm-short}.sh
    )

    for f in ''${REPLACE_FILES[*]}; do
        # substituteInPlace $f\
        #     --replace /bin/pwd $(type -P pwd)\
        #     --replace /bin/echo $(type -P echo)
        wrapProgram $f --set MATLAB_ARCH glnxa64 --set LD_LIBRARY_PATH ${mcrLibPath}
    done

    # The binary kinda breaks and looks for spm.ctf in .ctf... Let it be.
    ln -s $out/bin/${spm-short}.ctf $out/bin/.ctf

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

{ matlab-version
, mcr-major
, mcr-majorshort
, mcr-minor
, sha256

, stdenv
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
}:

let
  libPath = lib.makeLibraryPath [
    mesa_glu
    ncurses
    xorg.libXi
    xorg.libXext
    xorg.libXmu
    xorg.libXp
    xorg.libXpm
    xorg.libXrandr
    xorg.libXrender
    xorg.libXt
    xorg.libXtst
    xorg.libXxf86vm
    xorg.libX11
    zlib

    cacert
    alsa-lib # libasound2
    atk
    glib
    glibc
    cairo
    cups
    dbus
    fontconfig
    gdk-pixbuf
    #gst-plugins-base
    # gstreamer
    gtk3
    nspr
    nss
    pam
    pango
    #python3
    libselinux
    libsndfile
    libxcrypt
    glibcLocales
    procps
    unzip
    jre
  ];

in stdenv.mkDerivation {
  pname = "matlab-runtime";
  version = "${matlab-version}(${mcr-major}.${mcr-minor})";

  src = fetchzip {
    url = "https://ssd.mathworks.com/supportfiles/downloads/${matlab-version}/Release/${mcr-minor}/deployment_files/installer/complete/glnxa64/MATLAB_Runtime_${matlab-version}_Update_${mcr-minor}_glnxa64.zip";
    inherit sha256;
    stripRoot = false;
  };

  buildInputs = [
    autoPatchelfHook
    # zlib
  ];

  patchPhase = ''
    substituteInPlace install \
      --replace /bin/pwd $(type -P pwd) \
      --replace /bin/uname $(type -P uname)
    substituteInPlace bin/glnxa64/install_unix \
      --replace /bin/pwd $(type -P pwd) \
      --replace /bin/uname $(type -P uname)

    echo "Patching java..."
    patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${libPath}:$(patchelf --print-rpath sys/java/jre/glnxa64/jre/bin/java)"\
      --force-rpath "sys/java/jre/glnxa64/jre/bin/java"
  '';

  dontConfigure = true;
  dontBuild = true;
  installPhase = ''
    ./install -destinationFolder $PWD/build -agreeToLicense yes -mode silent

    mv build/v${mcr-majorshort} $out

    # I originally tried to symlink all the libs to one, sane location
    # But it seems the MCR doesn't like to follow symlinks for libs; nor rpath
    # Must be actually files on LD_LIBRARY_PATH

    # make /lib dir with required libs
    # mkdir -p $out/lib
    # find $out/runtime/glnxa64 -name "*.so*" -exec ln -v -s {} $out/lib \;
    # find $out/bin/glnxa64 -name "*.so*" -exec ln -v -s {} $out/lib \;
    # find $out/sys/os/glnxa64 -name "*.so*" -exec ln -v -s {} $out/lib \;
    # find $out/extern/bin/glnxa64 -name "*.so*" -exec ln -v -s {} $out/lib \;
  '';

  fixupPhase = ''
    PATCH_FILES=(
        # $out/bin/glnxa64/MATLAB
        $out/bin/glnxa64/matlab_helper
        # $out/bin/glnxa64/mcc
        # $out/bin/glnxa64/mbuildHelp
        # $out/bin/glnxa64/mex
        # $out/bin/glnxa64/need_softwareopengl
        $out/sys/java/jre/glnxa64/jre/bin/java
    )

    for f in ''${PATCH_FILES[*]}; do
        chmod u+w $f
        patchelf --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
          --set-rpath "$libPath:$(patchelf --print-rpath $f)"\
          --force-rpath $f
    done


    # Perhaps necessary, but I'm not using this so untested. Leaving it out.
    # # Set the correct path to gcc
    # CC_FILES=(
    #     $out/bin/mbuildopts.sh
    #     $out/bin/mexopts.sh
    # )
    # for f in ''${CC_FILES[*]}; do
    #     substituteInPlace $f\
    #         --replace "CC='gcc'" "CC='${gcc48}/bin/gcc'"
    # done
  '';

  passthru.matlab-version = matlab-version;
  # I wanted to conveniently pass thru the libs needing to be on LD_LIBRARY_PATH
  # But, it seems Nix lazily evaluates `placeholder "out"` such that it points to the output of the caller,
  # not this derivations output. And I don't know how else to referecne the output.
  # passthru.libPath = let
  #   out = placeholder "out";
  # in "${out}/runtime/glnxa64:${out}/bin/glnxa64:${out}/sys/os/glnxa64:${out}/extern/bin/glnxa64:${libPath}";
  passthru.libPath = libPath;

  meta = with lib; {
    description = "MATLAB runtime";
    longDescription = ''
      TODO
    '';
    homepage = "TODO";
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    license = licenses.unfree;
    maintainers = with maintainers; [ ashgillman ];
    platforms = platforms.linux;
  };
}

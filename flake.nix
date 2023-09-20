{
  description = "Statistical Paramtric Mapping w/ MATLAB Compiler Runtime";

  inputs = {
    # use the new nixpkgs to build the flake
    nixpkgs = {
      url = "github:NixOS/nixpkgs/22.11";
    };
    utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    utils,
    ...
  }@inputs: inputs.utils.lib.eachSystem [
    # Add the system/architecture you would like to support here. Note that not
    # all packages in the official nixpkgs support all platforms.
    "x86_64-linux" "i686-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"
  ] (system:
  let
    pkgs = import nixpkgs {
      inherit system;

      # Add overlays here if you need to override nixpkgs
      overlays = [ ];

      config = {
        # don't limit to open source packages
        allowUnfree = true;
      };
    };

  in {
    packages = rec {
      matlab-runtime = pkgs.callPackage ./matlab-runtime.nix {};
      spm-mcr = pkgs.callPackage ./spm-mcr.nix { inherit matlab-runtime; };
      default = spm-mcr;
    };
  });
}

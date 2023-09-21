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
      mcr-R2019a = pkgs.callPackage ./mcr/2019a.nix {};
      mcr-R2019b = pkgs.callPackage ./mcr/2019b.nix {};
      mcr = mcr-R2019b;

      spm8 = pkgs.callPackage ./spm/spm8.nix { matlab-runtime = mcr-R2019a; };
      spm12 = pkgs.callPackage ./spm/spm12.nix { matlab-runtime = mcr-R2019b; };
      spm = spm12;
      default = spm;
    };
  });
}

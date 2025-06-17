{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    tonywu20.url = "github:TonyWu20/nur-packages";
    castep_25_mkl.url = "git+ssh://git@github.com/TonyWu20/CASTEP-25.12-nixos";
    castep_25_aocl.url = "git+ssh://git@github.com/TonyWu20/CASTEP-25.12-nixos?ref=amd";
  };

  outputs = { nixpkgs, tonywu20, castep_25_mkl, castep_25_aocl, ... }:
    let
      system = "x86_64-linux";
      overlays = [ castep_25_mkl.overlays.default castep_25_aocl.overlays.default ];
      pkgs = import nixpkgs {
        config.allowUnfree = true;
        inherit system overlays;
      };
      intel-oneapi = tonywu20.packages.${system}.intel-oneapi-hpc;
      aocl = tonywu20.packages.${system}.amd-aocl;
    in
    {
      devShells.${system} = {
        mkl = pkgs.mkShell {
          packages = with pkgs; [
            fish
            intel-oneapi
            stdenv
            castep_25_12
          ];
          shellHook = ''
            source ${intel-oneapi}/setvars.sh
            export INTEL=${intel-oneapi}
            exec fish
          '';
        };
        aocl = pkgs.mkShell {
          packages = with pkgs; [
            fish
            aocl
            stdenv
            castep_25_12
          ];
          inputsFrom = with pkgs; [
            castep_25_12
          ];
          shellHook =
            ''
              export AOCL_HOME=${aocl}
              export LD_LIBRARY_PATH=${aocl}/${aocl.version}/${aocl.compiler}/lib:$LD_LIBRARY_PATH
              echo "With ${aocl.name} + ${pkgs.castep_25_12.pname}"
              exec fish
            '';
        };
      };

    };
}

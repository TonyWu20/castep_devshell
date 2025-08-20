{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    tonywu20.url = "github:TonyWu20/nur-packages";
    castep_25_mkl.url = "git+ssh://git@github.com/TonyWu20/CASTEP-25.12-nixos";
    castep_25_aocl.url = "git+ssh://git@github.com/TonyWu20/CASTEP-25.12-nixos?ref=amd";
    castep_611_custom.url = "git+ssh://git@github.com/TonyWu20/CASTEP-6.11-nixos-customized";
  };

  outputs = { nixpkgs, tonywu20, castep_25_mkl, castep_25_aocl, castep_611_custom, ... }:
    let
      system = "x86_64-linux";
      overlays = [ castep_25_mkl.overlays.default castep_25_aocl.overlays.default castep_611_custom.overlays.default ];
      pkgs = import nixpkgs {
        config.allowUnfree = true;
        inherit system overlays;
      };
      intel-oneapi = tonywu20.packages.${system}.intel-oneapi-hpc;
      aocl = tonywu20.packages.${system}.amd-aocl;
    in
    {
      devShells.${system} = {
        castep_25_mkl = pkgs.mkShell {
          packages = with pkgs; [
            fish
            intel-oneapi
            stdenv
            castep_25_12
          ];
          env = {
            OMP_NUM_THREADS = 1;
            INTEL = intel-oneapi;
            PATH = "${pkgs.gnumake}/bin:${pkgs.castep_611_mkl}/${pkgs.castep_611_mkl.arch}/bin:$PATH";
          };
          shellHook = ''
            source ${intel-oneapi}/setvars.sh
          '';
        };
        castep_25_aocl = pkgs.mkShell {
          packages = with pkgs; [
            fish
            aocl
            stdenv
            castep_25_12
          ];
          inputsFrom = with pkgs; [
            castep_25_12
            aocl
          ];
          env = {
            OMP_NUM_THREADS = 1;
            BLIS_NUM_THREADS = 1;
            AOCL_HOME = aocl;
            LD_LIBRARY_PATH = "${aocl}/${aocl.version}/${aocl.compiler}/lib:$LD_LIBRARY_PATH";
          };
          shellHook =
            ''
              echo "With ${aocl.name} + ${pkgs.castep_25_12.pname}"
            '';
        };
        castep_6_mkl = pkgs.mkShell {
          packages = with pkgs; [
            fish
            intel-oneapi
            stdenv
            castep_611_mkl
            gnumake
          ];
          inputsFrom = with pkgs; [
            intel-oneapi
            castep_611_mkl
          ];
          env = {
            OMP_NUM_THREADS = 1;
            INTEL = intel-oneapi;
            PATH = "${pkgs.gnumake}/bin:${pkgs.castep_611_mkl}/${pkgs.castep_611_mkl.arch}/bin:$PATH";
          };
          shellHook = ''
            source ${intel-oneapi}/setvars.sh
          '';

        };
        castep_6_aocl = pkgs.mkShell {
          packages = with pkgs; [
            fish
            aocl
            stdenv
            castep_611_aocl
          ];
          inputsFrom = with pkgs; [
            aocl
            castep_611_aocl
          ];
          env = {
            OMP_NUM_THREADS = 1;
            BLIS_NUM_THREADS = 1;
            AOCL_HOME = aocl;
            LD_LIBRARY_PATH = "${aocl}/${aocl.version}/${aocl.compiler}/lib:$LD_LIBRARY_PATH";
            PATH = "${pkgs.castep_611_aocl}/${pkgs.castep_611_aocl.arch}/bin:$PATH";
          };
          shellHook =
            ''
              echo "With ${aocl.name} + ${pkgs.castep_611_aocl.pname}"
            '';
        };
      };

    };
}

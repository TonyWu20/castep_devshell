{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    tonywu20.url = "github:TonyWu20/nur-packages";
    castep.url = "git+ssh://git@github.com/TonyWu20/CASTEP-25.12-nixos";
  };

  outputs = { nixpkgs, tonywu20, castep, ... }:
    let
      system = "x86_64-linux";
      overlays = [ castep.overlays.default ];
      pkgs = import nixpkgs {
        config.allowUnfree = true;
        inherit system overlays;
      };
      intel-oneapi = tonywu20.packages.${system}.intel-oneapi-hpc;
    in
    {
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = with pkgs; [
            fish
            intel-oneapi
            stdenv
          ];
          shellHook = ''
            source ${intel-oneapi}/setvars.sh
            export INTEL=${intel-oneapi}
            exec fish
          '';
        };
      };

    };
}

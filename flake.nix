{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nur.url = "github:TonyWu20/NUR";
    castep.url = "git+ssh://git@github.com/TonyWu20/CASTEP-25.12-nixos";
  };

  outputs = inputs@{ self, nixpkgs, nur, castep, ... }:
    let
      system = "x86_64-linux";
      overlays = [ nur.overlays.default castep.overlays.default ];
      pkgs = import nixpkgs {
        config.allowUnfree = true;
        inherit system overlays;
      };
      intel-oneapi = pkgs.nur.repos.tonywu20.intel-oneapi-hpc;
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
            exec fish
          '';
        };
      };

    };
}

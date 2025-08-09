{
  description = "Futatic";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs"; #?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    c3 = {
      url = "github:c3lang/c3c";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = 
    { 
      self,
      nixpkgs,
      flake-utils,
      c3,
    }: flake-utils.lib.eachDefaultSystem (system:
    let 
      pkgs = nixpkgs.legacyPackages."${system}";

      c3Packages = c3.packages."${system}";
    in 
    {
      devShells.default = pkgs.mkShell {
        packages = [
          c3Packages.c3c
        ];
      };
    })
  ;
}

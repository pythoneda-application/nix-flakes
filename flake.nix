{
  description = "Application layer of PythonEDA Nix Flakes";

  inputs = rec {
    nixos.url = "github:NixOS/nixpkgs/nixos-22.11";
    flake-utils.url = "github:numtide/flake-utils/v1.0.0";
    poetry2nix = {
      url = "github:nix-community/poetry2nix/v1.28.0";
      inputs.nixpkgs.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
    };
    pythoneda = {
      url = "github:pythoneda/base/0.0.1a7";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-infrastructure-base = {
      url = "github:pythoneda-infrastructure/base/0.0.1a5";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-application-base = {
      url = "github:pythoneda-application/base/0.0.1a5";
      inputs.pythoneda.follows = "pythoneda";
      inputs.pythoneda-infrastructure-base.follows =
        "pythoneda-infrastructure-base";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-nix-flakes = {
      url = "github:pythoneda/nix-flakes/0.0.1a2";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-infrastructure-nix-flakes = {
      url = "github:pythoneda-infrastructure/nix-flakes/0.0.1a2";
      inputs.pythoneda.follows = "pythoneda";
      inputs.pythoneda-infrastructure-base.follows =
        "pythoneda-infrastructure-base";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
  };
  outputs = inputs:
    with inputs;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixos { inherit system; };
        python = pkgs.python3;
        pythonPackages = python.pkgs;
        description = "Application layer of PythonEDA Nix Flakes";
        license = pkgs.lib.licenses.gpl3;
        homepage = "https://github.com/pythoneda-application/nix-flakes";
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          pythoneda-application-nix-flakes =
            pythonPackages.buildPythonPackage rec {
              pname = "pythoneda-application-nix-flakes";
              version = "0.0.1a2";
              src = ./.;
              format = "pyproject";

              nativeBuildInputs = [ pkgs.poetry ];

              propagatedBuildInputs = with pythonPackages; [
                pythoneda-application-base.packages.${system}.pythoneda-application-base
                pythoneda-infrastructure-nix-flakes.packages.${system}.pythoneda-infrastructure-nix-flakes
                pythoneda-nix-flakes.packages.${system}.pythoneda-nix-flakes
              ];

              checkInputs = with pythonPackages; [ pytest ];

              pythonImportsCheck = [ ];

              meta = with pkgs.lib; {
                inherit description license homepage maintainers;
              };
            };
          default = packages.pythoneda-application-nix-flakes;
          meta = with lib; {
            inherit description license homepage maintainers;
          };
        };
        defaultPackage = packages.default;
        devShell = pkgs.mkShell {
          buildInputs = with pkgs.python3Packages; [ packages.default ];
        };
        shell = flake-utils.lib.mkShell {
          packages = system: [ self.packages.${system}.default ];
        };
      });
}

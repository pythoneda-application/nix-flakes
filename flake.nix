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
      url = "github:rydnr/pythoneda/0.0.1a5";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-infrastructure-layer = {
      url = "github:rydnr/pythoneda-infrastructure-layer/0.0.1a2";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-application-layer = {
      url = "github:rydnr/pythoneda-application-layer/0.0.1a3";
      inputs.pythoneda.follows = "pythoneda";
      inputs.pythoneda-infrastructure-layer.follows =
        "pythoneda-infrastructure-layer";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-nix-flakes = {
      url = "github:rydnr/pythoneda-nix-flakes/0.0.1a1";
      inputs.pythoneda.follows = "pythoneda";
      inputs.nixos.follows = "nixos";
      inputs.flake-utils.follows = "flake-utils";
      inputs.poetry2nix.follows = "poetry2nix";
    };
    pythoneda-nix-flakes-infrastructure = {
      url = "github:rydnr/pythoneda-nix-flakes-infrastructure/0.0.1a1";
      inputs.pythoneda.follows = "pythoneda";
      inputs.pythoneda-infrastructure-layer.follows =
        "pythoneda-infrastructure-layer";
      inputs.pythoneda-git-repositories.follows = "pythoneda-git-repositories";
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
        maintainers = with pkgs.lib.maintainers; [ ];
      in rec {
        packages = {
          pythoneda-nix-flakes-application =
            pythonPackages.buildPythonPackage rec {
              pname = "pythoneda-nix-flakes-application";
              version = "0.0.1a1";
              src = ./.;
              format = "pyproject";

              nativeBuildInputs = [ pkgs.poetry ];

              propagatedBuildInputs = with pythonPackages; [
                pythoneda-application-layer.packages.${system}.pythoneda-application-layer
                pythoneda-nix-flakes.packages.${system}.pythoneda-nix-flakes
                pythoneda-nix-flakes-infrastructure.packages.${system}.pythoneda-nix-flakes-infrastructure
              ];

              checkInputs = with pythonPackages; [ pytest ];

              pythonImportsCheck = [ ];

              meta = with pkgs.lib; {
                inherit description license homepage maintainers;
              };
            };
          default = packages.pythoneda-nix-flakes-application;
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

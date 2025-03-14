{
  description = "Flake for running CadQuery-editor";

  inputs = {
    devenv-root = {
      url = "file+file:///dev/null";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:cachix/devenv-nixpkgs/rolling";
    devenv.url = "github:cachix/devenv";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";

    cadquery.url = "github:marcus7070/cq-flake";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs = inputs@{ flake-parts, devenv-root, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = [ "x86_64-linux" "i686-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      perSystem = { config, self', inputs', pkgs, system, ... }: {
        # Per-system attributes can be defined here. The self' and inputs'
        # module parameters provide easy access to attributes of the same
        # system.

        # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
        packages.default = pkgs.hello;

        devenv.shells.default = {
          devenv.root =
            let
              devenvRootFileContent = builtins.readFile devenv-root.outPath;
            in
            pkgs.lib.mkIf (devenvRootFileContent != "") devenvRootFileContent;

          name = "cadquery";

          #packages = [ inputs'.cadquery.packages.cq-editor ];
          packages = with pkgs; [
            libGL
            glib

            (stdenv.mkDerivation {
              pname = "cq-editor";
              version = "1.0";

              dontUnpack = true;

              nativeBuildInputs = [
                libsForQt5.qt5.wrapQtAppsHook
              ];

              propagatedBuildInputs = with python3Packages; [
                pyqt5
              ];

              installPhase = ''
                mkdir -p $out/bin
                script=$out/bin/cq-editor

                printf "%s\n" "#!/bin/sh" "CQ-editor" > $script
                chmod +x $script
              '';

              qtWrapperArgs = [ "--set QT_QPA_PLATFORM xcb" ];

              postFixup = ''
                wrapQtApp "$out/bin/cq-editor"
              '';
            })
          ];

          enterShell = ''
            source $UV_PROJECT_ENVIRONMENT/bin/activate
          '';

          languages.python = {
            enable = true;

            uv = {
              enable = true;
              sync.enable = true;
            };

            #venv = {
            #  enable = true;
            #  requirements = ''
            #    cq-queryabolt == 0.1.2
            #  '';
            #};
          };
        };
      };

      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.
      };
    };
}

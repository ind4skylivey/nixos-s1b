{
  description = "Python project (devShell: python3, uv, ruff, basedpyright)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShells = forAllSystems (
        pkgs:
        let
          python = pkgs.python3;
        in
        {
          default = pkgs.mkShell {
            packages = [
              python
              pkgs.uv
              pkgs.ruff
              pkgs.basedpyright
            ];
            # uv usa el python de Nix y nunca descarga intérpretes propios.
            UV_PYTHON = "${python}/bin/python3";
            UV_PYTHON_DOWNLOADS = "never";
            shellHook = ''
              # `uv sync` crea .venv; sus binarios quedan a mano.
              if [ -d .venv ]; then
                export VIRTUAL_ENV="$PWD/.venv"
                export PATH="$VIRTUAL_ENV/bin:$PATH"
              fi
            '';
          };
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}

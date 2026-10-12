{
  description = "PHP project (devShell: php 8.4, composer, phpactor)";

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
          php = pkgs.php84;
        in
        {
          default = pkgs.mkShell {
            packages = [
              php
              php.packages.composer
              pkgs.phpactor # LSP libre (intelephense es unfree)
            ];
            # Binarios instalados con `composer require --dev` (phpunit, php-cs-fixer…).
            shellHook = ''
              export PATH="$PWD/vendor/bin:$PATH"
            '';
          };
        }
      );

      formatter = forAllSystems (pkgs: pkgs.nixfmt);
    };
}

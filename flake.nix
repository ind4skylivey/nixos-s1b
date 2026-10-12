{
  description = "NixOS VM flake for LiveY: mango (Wayland) + stylix + home-manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # Solo para el toolchain de Rust de Strata (necesita rustc >= 1.96;
    # 26.05 trae 1.95). El resto del sistema sigue en 26.05.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix se mudó de danth/stylix a nix-community/stylix.
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # mangowm, fijado al tag 0.18.0.
    mango = {
      url = "github:mangowm/mango/0.18.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Navegador Helium (imputnet): flake comunitario que repaquetea el .deb oficial.
    helium = {
      url = "github:oxcl/nix-flake-helium-browser";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Base de datos precompilada para nix-index / comma.
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Encrypted secrets via sops-nix + age. Private key lives at
    # ~/.config/sops/age/keys.txt on the machine (never in this repo).
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Solo como fuente de referencia (configs originales); no es un flake.
    hakuspace = {
      url = "github:hakuimaku/hakuspace/v26.10-1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      stylix,
      mango,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/vm

          mango.nixosModules.mango
          stylix.nixosModules.stylix
          home-manager.nixosModules.home-manager

          ./modules/mango.nix
          ./modules/stylix.nix
          ./modules/vm-guest.nix
          ./modules/login.nix
          ./modules/locale.nix
          ./modules/nix-tools.nix
          inputs.sops-nix.nixosModules.sops
          ./modules/sops.nix

          {
            nix.settings.experimental-features = [
              "nix-command"
              "flakes"
            ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-bak";
              extraSpecialArgs = { inherit inputs; };
              sharedModules = [
                mango.hmModules.mango
                inputs.nix-index-database.homeModules.nix-index
              ];
              users.s1b = import ./home/s1b/home.nix;
            };
          }
        ];
      };

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt;

      # Plantillas de proyecto: `nix flake init -t ~/nixos-mango#rust`
      # (o `newproj rust mi-app`). Cada una trae devShell + .envrc + .gitignore.
      templates = {
        rust = {
          path = ./templates/rust;
          description = "Rust: rustc, cargo, clippy, rustfmt, rust-analyzer";
          welcomeText = "Rust devShell ready. Run `direnv allow`, then `cargo init`.";
        };
        php = {
          path = ./templates/php;
          description = "PHP 8.4: composer, phpactor";
          welcomeText = "PHP devShell ready. Run `direnv allow`, then `composer init`.";
        };
        python = {
          path = ./templates/python;
          description = "Python 3: uv, ruff, basedpyright";
          welcomeText = "Python devShell ready. Run `direnv allow`, then `uv init`.";
        };
      };

      # Shells opcionales (no van en el sistema base).
      #   nix develop ~/nixos-mango#sec
      #   nix develop ~/nixos-mango#re
      devShells.${system} =
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          sec = pkgs.mkShell {
            name = "mango-sec";
            packages = with pkgs; [
              nmap
              rustscan
              masscan
              wireshark-cli
              tcpdump
              netcat-openbsd
              socat
              ffuf
              gobuster
              sqlmap
              nuclei
              hashcat
              john
              thc-hydra
              radare2
              gdb
              gef
              binwalk
              (python3.withPackages (
                ps: with ps; [
                  pwntools
                  requests
                  impacket
                ]
              ))
            ];
            shellHook = ''
              echo "▸ mango-sec: nmap rustscan masscan tshark ffuf gobuster sqlmap nuclei hashcat john hydra radare2 gdb+gef binwalk pwntools"
            '';
          };
          re = pkgs.mkShell {
            name = "mango-re";
            packages = with pkgs; [
              ghidra
              radare2
              gdb
              gef
              binwalk
              (python3.withPackages (ps: with ps; [ pwntools ]))
            ];
            shellHook = ''
              echo "▸ mango-re: ghidra radare2 gdb+gef binwalk pwntools (pesado)"
            '';
          };
        };
    };
}

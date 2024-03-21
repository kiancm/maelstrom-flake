{
  description = "Maelstrom";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      drv = system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          buildScript = jar: pkgs.writeShellScript "maelstrom.sh" ''
            exec java -Djava.awt.headless=true -jar "${jar}" "$@"
          '';
        in
        pkgs.stdenv.mkDerivation rec {
          pname = "maelstrom";
          version = "0.2.3";
          src = pkgs.fetchzip {
            url = "https://github.com/jepsen-io/maelstrom/releases/download/v${version}/maelstrom.tar.bz2";
            sha256 = "sha256-mE/FIHDLYd1lxAvECZGelZtbo0xkQgMroXro+xb9bMI=";
          };
          script = buildScript "${src}/lib/maelstrom.jar";
          nativeBuildInputs = [ pkgs.makeWrapper ];
          installPhase = ''
            mkdir -p $out/lib/
            cp $src/lib/maelstrom.jar $out/lib/
            install -m755 -D ${script} $out/bin/maelstrom
          '';
          postFixup = ''
            wrapProgram $out/bin/maelstrom \
              --set PATH ${pkgs.lib.makeBinPath [
                pkgs.openjdk21
                pkgs.gnuplot
                pkgs.graphviz
                pkgs.git
              ]}
          '';
        };
    in
    {
      packages."x86_64-linux".default = drv "x86_64-linux";
      packages."aarch64-darwin".default = drv "aarch64-darwin";
    };
}

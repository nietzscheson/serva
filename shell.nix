{ pkgs ? import <nixpkgs> {} }:


let
  # Especificar la versión específica de Filebeat con el hash correcto
  filebeat68 = pkgs.stdenv.mkDerivation {
    name = "filebeat-6.8.0";
    version = "6.8.0";
    src = pkgs.fetchurl {
      url = "https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.8.0-linux-x86_64.tar.gz";
      sha256 = "0zxl9v3k0ig5d74vlaszqhk3q7qc3xa5bgl2ymmrswvwb16yjn9y";  # Hash actualizado
    };
    phases = [ "unpackPhase" "installPhase" ];

    unpackPhase = ''
      tar -xzf $src
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp filebeat-6.8.0-linux-x86_64/filebeat $out/bin/
      chmod +x $out/bin/filebeat
    '';
  };

in

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cmake
    jq
    #redis
    #logstash
    #elasticsearch
    #kibana
  ];

  buildInputs = [
    filebeat68
  ];

  packages = with pkgs; [
    git
    neovim
    httpie
  ];

  GIT_EDITOR = "${pkgs.neovim}/bin/nvim";

  shellHook = ''
    echo "Starting Redis server..."
    export PATH=$PATH:${filebeat68}/bin

    filebeat -c ./elk/filebeat/filebeat.yml
  '';
}
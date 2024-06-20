{ pkgs ? import <nixpkgs> {} }:

let
  pythonEnv = pkgs.python311.withPackages (ps: [
    ps.pip
    ps.debugpy
    ps.ipython
  ]);
in

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    cmake
    poetry
    jq
  ];

  buildInputs = [
    pythonEnv
  ];

  packages = with pkgs; [
    git
    neovim
    python311
    httpie
    ruff
    pre-commit
    go-task
  ];

  GIT_EDITOR = "${pkgs.neovim}/bin/nvim";

  shellHook = ''
    pyenv global system
    export PATH=$PATH:${pythonEnv}/bin
    poetry env use ${pythonEnv}/bin/python
  '';
}
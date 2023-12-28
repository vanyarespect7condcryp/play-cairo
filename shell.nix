# Adaption of https://github.com/age-of-eykar/contract/blob/315a7477233938233e14cd17df934652a1821a0c/shell.nix
with import <nixpkgs> { };

let pythonPackages = python3Packages;
in pkgs.mkShell rec {
  name = "impurePythonEnv";
  venvDir = "./venv";
  buildInputs = [
    # A Python interpreter including the 'venv' module is required to bootstrap
    # the environment.
    pythonPackages.python

    # This execute some shell code to initialize a venv in $venvDir before
    # dropping into the shell
    pythonPackages.venvShellHook

    # required by fastecdsa
    gmp
  ];

  # Run this command, only after creating the virtual environment
  postVenvCreation = ''
    unset SOURCE_DATE_EPOCH
    pip install -r requirements.txt
  '';

  # Now we can execute any commands within the virtual environment.
  # This is optional and can be left out to run pip manually.
  postShellHook = ''
    # allow pip to install wheels
    unset SOURCE_DATE_EPOCH
  '';
}
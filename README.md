# Cairo Playground

## Setup

1. [Build Protostar](#building-protostar)
2. `git clone <url>`
3. `mkdir bin`
4. [Setup Binary](#binary-setup)
5. `nix-shell`
6. `starknet-devnet`

_Optional_: Update the `cairo.cairoFormatPath` property in the `.vscode/settings.json` file. Run `which cairo-format` within a Poetry shell to get the project-specific `cairo-format` path.

_Optional_: Update the `python.formatting.blackPath` property in the `.vscode/settings.json` file. Run `which black` within a Poetry shell to get the project-specific `black` path.

## Useful Commands

```sh
# Nix
nix-shell

# StarkNet DevNet
starknet-devnet

# Protostar
./protostar init [--existing]
./protostar test ./tests [--safe-collecting]
./protostar build
./protostar install
./protostar install <url>
./protostar update
./protostar update <submodule-name>
./protostar remove <submodule-name>
./protostar deploy ./build/<name>.json --network <name> [--inputs ...]

# With `protostar.toml` Updates
./protostar -p testnet deploy ./build/<name>.json

# Symlinks
ln -sf ./bin/dist/protostar/protostar protostar
```

## Useful Resources

### StarkNet

- https://starknet.io
- https://starknet.io/what-is-starknet
- https://starknet.io/building-on-starknet
- https://starknet.io/building-on-starknet/developer-tools
- https://starknet.io/playground
- https://docs.starknet.io/docs/Intro
- https://starknet-ecosystem.com
- https://github.com/gakonst/awesome-starknet

### Cairo

- https://docs.starknet.io
- https://cairo-lang.org
- https://cairo-lang.org/docs
- https://cairo-lang.org/playground
- https://cairo-by-example.org

### Protostar

- https://docs.swmansion.com/protostar
- https://github.com/onlydustxyz/protostar-vs-nile
- https://github.com/software-mansion/protostar/tree/master/website/docs

## Building Protostar

1. `git clone git@github.com:software-mansion/protostar.git`
2. `cd protostar`
3. `touch shell.nix`
4. Update `shell.nix` file (see below)
5. `nix-shell`
6. `python -m venv .venv`
7. `source .venv/bin/activate`
8. `pip install --upgrade pip`
9. `pip install poetry`
10. `poetry install`
11. `poe test`
12. `poe build`

Binaries can be found in the `dist` directory.

### `shell.nix` file

```nix
# shell.nix file
{ pkgs ? import <nixpkgs> { } }:

with pkgs;

mkShell {
  buildInputs = [
    python37Full
    darwin.apple_sdk.frameworks.Accelerate
    gmp
  ];
}
```

## Binary Setup

**Note:** Requires the binary to be built (see above).

1. `cd <path-to-protostar-project-root-directory>`
2. `cp -r dist/ ~/Desktop/`
3. `cd ~/Desktop`
4. `mv ./dist <path-to-project-root-directory>/bin`
5. `ln -sf ./bin/dist/protostar/protostar protostar`
6. `./protostar test`

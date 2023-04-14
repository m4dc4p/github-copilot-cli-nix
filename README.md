This repo defines a Nix flake that can be used to install
or run the Github Copilot CLI.

It uses a fixed version of the CLI (0.1.32 initially), as
found on npm at https://www.npmjs.com/package/@githubnext/github-copilot-cli.

To see help:

    nix run . -- --help

To authenticate:

    nix run . -- auth


etc.


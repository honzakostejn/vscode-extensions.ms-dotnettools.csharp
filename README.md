# vscode-extensions.ms-dotnettools.csharp
Nix development shell to reproduce debugging bug in the latest nix package revision.

# How to reproduce?
This repo assumes the following:
- you have flakes enabled
- you have nix-ld enabled

1. Clone the repo.
1. Run `nix develop`.
1. Run `code .` to open vscode.
1. Once vscode is fully loaded, then hit `F5`. The project is successfully built,
but the debugging session **does not** start.

# Older revision
I believe this is a regression bug since the debugging works just fine with older revision.

You can comment line #48 and uncomment line #49 in the `flake.nix` and repeat instructions from above.
Now the debugging starts and you hit your breakpoint.
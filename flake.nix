{
  description = "dotnet development shell";

  inputs = {
    nixpkgs = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      ref = "refs/heads/nixos-unstable";
    };

    nixpkgs_pinned_csharp = {
      type = "github";
      owner = "nixos";
      repo = "nixpkgs";
      rev = "c792c60b8a97daa7efe41a6e4954497ae410e0c1";
    };
  };

  outputs = { self, nixpkgs, nixpkgs_pinned_csharp }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { system = "x86_64-linux"; config.allowUnfree = true; };
      pinned_csharp_pkgs = import nixpkgs_pinned_csharp { system = "x86_64-linux"; config.allowUnfree = true; };
      dotnetPkg = (with pkgs.dotnetCorePackages; combinePackages [
        sdk_8_0_3xx
        sdk_9_0
      ]);
      debugging_not_working_vscode = pkgs.vscode-with-extensions.override
        {
          vscodeExtensions = with pkgs.vscode-extensions; [
            ms-dotnettools.vscode-dotnet-runtime
            ms-dotnettools.csharp
            ms-dotnettools.csdevkit
          ];
        };
      debugging_working_vscode = pkgs.vscode-with-extensions.override
        {
          vscodeExtensions = with pkgs.vscode-extensions; [
            ms-dotnettools.vscode-dotnet-runtime
            ms-dotnettools.csdevkit
          ] ++ [
            pinned_csharp_pkgs.vscode-extensions.ms-dotnettools.csharp
          ];
        };
      deps = [
        dotnetPkg
        debugging_not_working_vscode
        # debugging_working_vscode
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        name = "dotnet-development-shell";

        # requires nix-ld to be enabled
        # nix-ld allows unpatched dynamic binaries to run on NixOS
        NIX_LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath ([
          pkgs.stdenv.cc.cc
        ] ++ deps);
        NIX_LD = "${pkgs.stdenv.cc.libc_bin}/bin/ld.so";
        nativeBuildInputs = [
        ] ++ deps;

        shellHook = ''
          # set environment variables
          export DOTNET_ROOT="${dotnetPkg}/share/dotnet";
        '';
      };
    };
}

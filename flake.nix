{
  inputs = {
    systems.url = "github:nix-systems/default";

    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";

    gleam2nix.url = "github:mtoohey31/gleam2nix";
    gleam2nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs:
    let
      mapSystems =
        systems: f:
        systems
        |> map (s: f s |> builtins.mapAttrs (_: v: { ${s} = v; }))
        |> builtins.zipAttrsWith (_: builtins.foldl' (a: b: a // b) { });
    in
    mapSystems (import inputs.systems) (
      system:
      let
        pkgs = inputs.nixpkgs.legacyPackages.${system}.appendOverlays [
          inputs.gleam2nix.overlays.default
          (self: super: {
            plushie-renderer = self.callPackage ./plushie-renderer.nix { };
            elixir = self.beamPackages.elixir;
          })
        ];
        notepad_gui = pkgs.callPackage ./default.nix { };
        inherit (pkgs) lib;
      in
      {
        packages.plushie-renderer = pkgs.plushie-renderer;
        packages.default = notepad_gui;

        apps.default = {
          type = "app";
          program = lib.getExe notepad_gui;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ notepad_gui ];
          packages = with pkgs; [ elixir ];
          PLUSHIE_BINARY_PATH = lib.getExe pkgs.plushie-renderer;
        };
      }
    );
}

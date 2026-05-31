{
  lib,
  buildGleamProgram,
  erlang,
  plushie-renderer,
}:

(buildGleamProgram { src = ./.; }).overrideAttrs (superAttrs: {
  buildInputs = (superAttrs.buildInputs or [ ]) ++ [ plushie-renderer ];

  # Copy-pasted makeWrapper to avoid double-wrapping https://github.com/mtoohey31/gleam2nix/blob/main/build-gleam-program.nix
  postInstall = ''
    rm $out/bin/notepad_gui
    makeWrapper $out/share/gleam/notepad_gui/entrypoint.sh $out/bin/notepad_gui \
      --add-flags run \
      --prefix PATH : ${lib.getBin erlang}/bin \
      --set PLUSHIE_BINARY_PATH ${lib.getExe plushie-renderer}
  '';

  meta = {
    license = lib.licenses.unlicense;
    mainProgram = "notepad_gui";
  };
})

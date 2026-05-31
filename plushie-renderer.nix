{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  libX11,
  libXcursor,
  libXi,
  libxkbcommon,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "plushie-renderer";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "plushie-ui";
    repo = "plushie-rust";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OGdqgnSNEt+BnJ4VYco+eWITxg3FEy5XBJAyezxxYxw=";
  };

  cargoHash = "sha256-L+I0Wt/WOzmU5B62eNWBg8kqXZ20nRbTLdRJfuvT0V8=";

  # Wayland and X11 libs are required at runtime since winit uses dlopen.
  runtimeDependencies = lib.optionals stdenv.hostPlatform.isLinux [
    libX11
    libXcursor
    libXi
    libxkbcommon
    wayland
  ];

  postFixup = ''
    patchelf $out/bin/plushie-renderer --add-rpath ${lib.makeLibraryPath finalAttrs.runtimeDependencies}
  '';

  cargoBuildFlags = [ "-p=plushie-renderer" ];

  meta = {
    description = "Native GUI renderer driven by a wire protocol over stdin/stdout";
    homepage = "https://github.com/plushie-ui/plushie-rust";
    license = [
      lib.licenses.asl20
      lib.licenses.mit
    ];
    mainProgram = "plushie-renderer";
  };
})

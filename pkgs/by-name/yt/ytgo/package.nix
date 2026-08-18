{
  lib,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  mpv,
}:

buildGoModule (finalAttrs: {
  pname = "ytgo";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "ytgo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OIHBl/CfzMtp9VLp/blyd7REBiqRduYTvRnWsXel/Yk=";
  };

  vendorHash = "sha256-xGRNbgRzV1dT4q3QtOTr3ybAmxI5OPYiH8PHdCoZBUQ=";

  __structuredAttrs = true;

  subPackages = [ "." ];

  nativeBuildInputs = [ makeWrapper ];

  postFixup = ''
    wrapProgram $out/bin/ytgo --prefix PATH : ${lib.makeBinPath [ mpv ]}
  '';

  meta = {
    description = "Minimalistic local-first YouTube TUI client";
    homepage = "https://github.com/jim-ww/ytgo";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "ytgo";
  };
})

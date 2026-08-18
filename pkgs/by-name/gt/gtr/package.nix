{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "gtr";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "gtr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3dDDygfIf7HXD0YJdQK5lvX59MhZ7weBmywOvLFuwHo=";
  };

  vendorHash = null;

  __structuredAttrs = true;

  doCheck = false;

  meta = {
    description = "Translate text from the command line using Google Translate";
    homepage = "https://github.com/jim-ww/gtr";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "gtr";
  };
})

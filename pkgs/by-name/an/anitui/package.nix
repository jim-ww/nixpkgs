{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "anitui";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "anitui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-oPgg2yJ+jU1RD1F38X3sVqfeCGTBKZtQfyfBy4yIl8Y=";
  };

  vendorHash = "sha256-E0or4WOKSelGttkW++x12YWqNBIgpyNFKoWkq8FCVcQ=";

  __structuredAttrs = true;

  meta = {
    description = "Terminal anime watch-list manager";
    homepage = "https://github.com/jim-ww/anitui";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "anitui";
  };
})

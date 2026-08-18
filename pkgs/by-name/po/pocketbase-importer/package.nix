{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "pocketbase-importer";
  version = "1.2.2";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "pocketbase-importer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-7L2km311UlzNh4c4Yi+o0DWqhS+zzZgyE9XA/nAwvns=";
  };

  vendorHash = "sha256-iYaXoASv3jKE0xT+FFSVlyPsVLgtaEzvHkyh0SNXLRU=";

  __structuredAttrs = true;

  meta = {
    description = "Small, fast CLI tool to bulk-import CSV files into PocketBase collections";
    homepage = "https://github.com/jim-ww/pocketbase-importer";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "pocketbase-importer";
  };
})

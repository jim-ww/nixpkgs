{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "janitor-scraper";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "janitor-scraper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4c9ngbnOidzIlY6WHOlZNwRVot66KxvmQXOmeO4/osU=";
  };

  vendorHash = "sha256-4VfMBmyE2vrhWxZoCRk2avM+iZXKJKsM/J/b7rOO0qo=";

  __structuredAttrs = true;

  meta = {
    description = "Fetches character descriptions and messages from Janitor AI in a clean, readable format";
    homepage = "https://github.com/jim-ww/janitor-scraper";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "janitor-scraper";
  };
})

{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "nihongo";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "nihongo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VBPlTDw/NnWuN+09TsuURMrdRHP1msuVObZsNrp5t0Y=";
  };

  vendorHash = "sha256-j6zMVJkzNK+s07SowF3FVt5DwgnQPWctZtpljRBGi50=";

  __structuredAttrs = true;

  meta = {
    description = "Minimal, blazing-fast Japanese dictionary CLI tool powered by Yomitan-compatible dictionaries";
    homepage = "https://github.com/jim-ww/nihongo";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "nihongo";
  };
})

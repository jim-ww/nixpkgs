{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule (finalAttrs: {
  pname = "shiraberu";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "shiraberu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ty+oA2ftySf+e+SSJ5pEOtClGlkIjIQDQSUBHuuR54Y=";
  };

  vendorHash = "sha256-ZbfzjgK/6GqArUuKLtCgLgEv1Rp0/FSRylzOPcYjhf8=";

  subPackages = [ "cmd/shiraberu" ];

  __structuredAttrs = true;

  meta = {
    description = "Multi-engine search aggregator that queries DuckDuckGo, Startpage, Bing, and more in parallel without API keys";
    homepage = "https://github.com/jim-ww/shiraberu";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "shiraberu";
  };
})

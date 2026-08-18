{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  makeWrapper,
  xdg-utils,
  procps,
}:

buildGoModule (finalAttrs: {
  pname = "itpec-sensei";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "itpec-sensei";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sjZzRGNnV1bp9RbNoAEnZLuJyoILAGxl26zf1n+7dOc=";
  };

  vendorHash = "sha256-pFWc1rUGPL0KQyeshK79B7CkuzpbSRhHzt854JTfRb4=";

  __structuredAttrs = true;

  nativeBuildInputs = [
    installShellFiles
    makeWrapper
  ];

  postInstall = ''
    installShellCompletion --cmd itpec-sensei \
      --bash <($out/bin/itpec-sensei completion bash) \
      --zsh <($out/bin/itpec-sensei completion zsh) \
      --fish <($out/bin/itpec-sensei completion fish)
  '';

  # `serve --image-viewer` (default xdg-open) and its cleanup path shell out
  # to open/close question images on the machine running the MCP server;
  # `cmd image` (bare CLI image viewer) does the same. Neither is on PATH by
  # default in a Nix build.
  postFixup = ''
    wrapProgram $out/bin/itpec-sensei --prefix PATH : ${
      lib.makeBinPath [
        xdg-utils
        procps
      ]
    }
  '';

  meta = {
    description = "Local-first CLI and MCP server for ITPEC exam practice";
    homepage = "https://github.com/jim-ww/itpec-sensei";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "itpec-sensei";
  };
})

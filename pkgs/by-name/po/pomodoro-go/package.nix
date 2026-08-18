{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  makeWrapper,
  libnotify,
}:

buildGoModule (finalAttrs: {
  pname = "pomodoro-go";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "pomodoro-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KyA6/NqWUF2D/UAqE+p00v330cD9Qk2KdMjTa/1ALl4=";
  };

  vendorHash = "sha256-5pGJXObrNkUtIxBV3xJi0k04M+++olVRQJTqxbPZb4g=";

  __structuredAttrs = true;

  nativeBuildInputs = [ makeWrapper ];

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapProgram $out/bin/pomodoro-go \
      --prefix PATH : ${lib.makeBinPath [ libnotify ]}
  '';

  meta = {
    description = "Command-line Pomodoro timer with desktop notifications";
    homepage = "https://github.com/jim-ww/pomodoro-go";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "pomodoro-go";
  };
})

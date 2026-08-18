{
  lib,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  alsa-lib,
}:

buildGoModule (finalAttrs: {
  pname = "mugo";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "mugo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-QEA21kzk29Lsgr2Zlzvw6y7B2drpn+rk9sLoovm0YBU=";
  };

  vendorHash = "sha256-t7hDuOFwWADF65AqepaY75sE8uiO3S7qyQyUKp4eHKE=";

  __structuredAttrs = true;

  # ebitengine/oto (audio playback) links against libasound via cgo on
  # Linux, see upstream's flake.nix.
  env.CGO_ENABLED = 1;

  buildInputs = [ alsa-lib ];
  nativeBuildInputs = [ pkg-config ];

  meta = {
    description = "Minimal terminal music player with MPRIS support";
    homepage = "https://github.com/jim-ww/mugo";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "mugo";
  };
})

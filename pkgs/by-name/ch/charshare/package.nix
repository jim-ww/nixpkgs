{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  pnpm,
  pkg-config,
  makeWrapper,
  makeDesktopItem,
  ffmpeg,
  gtk3,
  webkitgtk_4_1,
  gst_all_1,
  gsettings-desktop-schemas,
  glib-networking,
  cacert,
}:

let
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "charshare";
    tag = "v${version}";
    hash = "sha256-0RQDrPKE89jh7VPE4qpoeRmO4MWxw/ZaVpCBjTjxjfc=";
  };

  # Wails v3's Linux backend defaults to GTK4 + webkitgtk-6.0; this nixpkgs
  # only ships the older GTK3 + webkitgtk-4.1 ABI, so both the build and the
  # runtime wrapper select that backend via the `gtk3` Go build tag (see
  # wails' internal/assetserver/webview's *_linux_gtk3.go files).
  webkitDeps = lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    webkitgtk_4_1
    # WebKitGTK's <video>/<audio> playback goes through GStreamer, not a
    # built-in decoder; without these plugins present the webview hangs
    # instead of failing cleanly when asked to play media.
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  # GStreamer doesn't scan Nix store paths by default the way it would FHS
  # system dirs - needs GST_PLUGIN_SYSTEM_PATH_1_0 pointed at each plugin
  # package's lib/gstreamer-1.0 explicitly.
  gstPluginPath = lib.makeSearchPathOutput "lib" "lib/gstreamer-1.0" [
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  desktopItem = makeDesktopItem {
    name = "charshare";
    desktopName = "Charshare";
    comment = "Decentralized, unmoderated platform to share and talk to AI characters";
    exec = "charshare";
    icon = "charshare";
    categories = [
      "Network"
      "Chat"
    ];
  };

  # main.go embeds frontend/dist at compile time via `//go:embed
  # all:frontend/dist`, so the SvelteKit app needs to be built into a static
  # site first.
  frontendDist = stdenv.mkDerivation {
    pname = "charshare-frontend";
    inherit version;
    src = "${src}/frontend";

    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
    ];

    pnpmDeps = fetchPnpmDeps {
      pname = "charshare-frontend";
      inherit version;
      src = "${src}/frontend";
      fetcherVersion = 4;
      hash = "sha256-JDW/IDDSVmK98JpdRZhwSVvbLbqqEfEwkUCw9zxSBNU=";
    };

    # legal/license/+page.ts imports the repo-root LICENSE and
    # LICENSE-ASSETS files via relative paths that reach outside frontend/ -
    # copy them into place one level up before building.
    preBuild = ''
      cp ${src}/LICENSE ../LICENSE
      cp ${src}/LICENSE-ASSETS ../LICENSE-ASSETS
    '';

    buildPhase = ''
      runHook preBuild
      pnpm run build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp -r dist $out
      runHook postInstall
    '';
  };
in
buildGoModule {
  pname = "charshare";
  inherit version src;

  vendorHash = "sha256-GbqPNTbAt46GGAOmYIzu7jIQomaJsNvAsHz9I9OOQ6Y=";

  # `go mod vendor` (buildGoModule's default) unconditionally resolves every
  # dependency's go:embed patterns for every GOOS/GOARCH, and Wails v3's
  # alpha releases ship a Windows-only embed
  # (internal/webview2/webviewloader: arm64/WebView2Loader.dll) missing from
  # the published module zip - this fails even on linux, which never
  # touches that package. proxyVendor uses `go mod download` instead, which
  # doesn't do that resolution.
  proxyVendor = true;

  # buildGoModule's vendor-fetch derivation inherits preBuild by default,
  # which would otherwise drag in frontendDist (and its unrelated build)
  # just to compute the Go module hash.
  overrideModAttrs = _: {
    preBuild = "";
  };

  __structuredAttrs = true;

  # Only build the actual app - build/android/scripts/deps is an unrelated
  # helper for provisioning the Android SDK/NDK from the `wails3
  # task android:*` devShell workflow, not something end users need.
  subPackages = [ "." ];

  # "desktop" and "production" mirror what `wails build` normally passes
  # itself; without them the binary panics at startup with "Wails
  # applications will not build without the correct build tags". "gtk3"
  # selects the GTK3/webkitgtk-4.1 backend - see webkitDeps above.
  tags = [
    "desktop"
    "production"
    "gtk3"
  ];

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    ffmpeg
  ];
  buildInputs = webkitDeps;

  preBuild = ''
    rm -rf frontend/dist
    cp -r ${frontendDist} frontend/dist
  '';

  # Desktop-menu entry + icon, so package managers that aggregate
  # share/{applications,icons} (NixOS, home-manager) surface a real launcher
  # item instead of just a binary on PATH. 512x512 (not the raw 1024
  # source) because hicolor's index.theme only declares a fixed set of
  # standard size directories.
  postInstall = ''
    install -Dm644 ${desktopItem}/share/applications/*.desktop \
      $out/share/applications/charshare.desktop
    mkdir -p $out/share/icons/hicolor/512x512/apps
    ffmpeg -y -i frontend/static/logo.png -vf scale=512:512 \
      $out/share/icons/hicolor/512x512/apps/charshare.png
  '';

  postFixup = ''
    wrapProgram $out/bin/charshare \
      --suffix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}" \
      --set GIO_EXTRA_MODULES "${glib-networking}/lib/gio/modules" \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set NIX_SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set GST_PLUGIN_SYSTEM_PATH_1_0 "${gstPluginPath}"
  '';

  meta = {
    description = "Decentralized, unmoderated platform to share and talk to AI characters";
    homepage = "https://github.com/jim-ww/charshare";
    license = lib.licenses.agpl3Only;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "charshare";
  };
}

{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
  pkg-config,
  makeWrapper,
  gtk3,
  webkitgtk_4_1,
  gst_all_1,
  gsettings-desktop-schemas,
  glib-networking,
  cacert,
}:

let
  # Wails v3's Linux backend defaults to GTK4 + webkitgtk-6.0; this nixpkgs
  # only ships the older GTK3 + webkitgtk-4.1 ABI, so both the build and the
  # runtime wrapper select that backend via the `gtk3` Go build tag (see
  # wails' internal/assetserver/webview's *_linux_gtk3.go files).
  webkitDeps = lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    webkitgtk_4_1
    # WebKitGTK's media pipeline (audio/video elements, getUserMedia) goes
    # through GStreamer; without these plugins present it can't find basic
    # elements, and can fail to play video entirely.
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
in
buildGoModule (finalAttrs: {
  pname = "gowebwrap";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "jim-ww";
    repo = "gowebwrap";
    tag = "v${finalAttrs.version}";
    hash = "sha256-qP/6ZQ6/nAKXH2XFLxXmBUBUpWogJuvkVzOXy8utQsg=";
  };

  vendorHash = "sha256-3/QiXWNrQSGvkiEe8zfva9iPHAkeBSJ8kAOdr4IFfoQ=";

  # `go mod vendor` (buildGoModule's default) unconditionally resolves every
  # dependency's go:embed patterns for every GOOS/GOARCH, and Wails v3's
  # alpha releases ship a Windows-only embed
  # (internal/webview2/webviewloader: arm64/WebView2Loader.dll) missing from
  # the published module zip - this fails even on linux, which never
  # touches that package. proxyVendor uses `go mod download` instead, which
  # doesn't do that resolution.
  proxyVendor = true;

  __structuredAttrs = true;

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
  ];
  buildInputs = webkitDeps;

  # Same runtime env the upstream flake's devShell/package both set (GTK
  # schemas, TLS certs, GStreamer plugins for the webview) - needed here too
  # since an installed binary doesn't go through a devShell's shellHook.
  postFixup = ''
    wrapProgram $out/bin/gowebwrap \
      --suffix XDG_DATA_DIRS : "${gsettings-desktop-schemas}/share/gsettings-schemas/${gsettings-desktop-schemas.name}:${gtk3}/share/gsettings-schemas/${gtk3.name}" \
      --set GIO_EXTRA_MODULES "${glib-networking}/lib/gio/modules" \
      --set SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set NIX_SSL_CERT_FILE "${cacert}/etc/ssl/certs/ca-bundle.crt" \
      --set GST_PLUGIN_SYSTEM_PATH_1_0 "${gstPluginPath}"
  '';

  meta = {
    description = "Thin, config-driven desktop wrapper that turns any URL into a native webview app";
    homepage = "https://github.com/jim-ww/gowebwrap";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jim-ww ];
    mainProgram = "gowebwrap";
    platforms = lib.platforms.linux;
  };
})

{ config, pkgs, lib, ... }:

let
  strata = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "strata";
    version = "1.1.1";

    src = pkgs.fetchurl {
      url = "https://github.com/lgse/strata/releases/download/v${finalAttrs.version}/strata-${finalAttrs.version}-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-4FUuB3L83tE6gohHR7KPCzIiCjKTHNpuVfg1dbvlBzQ=";
    };

    dontStrip = true;

    nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.wrapGAppsHook4 ];
    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      gtk4
      pango
      cairo
      gdk-pixbuf
      graphene
      glib
      poppler
      fontconfig
      gtksourceview5
      gst_all_1.gstreamer
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
    ];

    installPhase = ''
      runHook preInstall
      install -Dm755 strata $out/bin/strata
      install -Dm644 io.github.lgse.Strata.desktop $out/share/applications/io.github.lgse.Strata.desktop
      install -Dm644 io.github.lgse.Strata.svg $out/share/icons/hicolor/scalable/apps/io.github.lgse.Strata.svg
      runHook postInstall
    '';

    meta = {
      description = "Keyboard-first GTK4 file manager";
      homepage = "https://github.com/lgse/strata";
      license = lib.licenses.mit;
      mainProgram = "strata";
      platforms = [ "x86_64-linux" ];
    };
  });
in
{
  environment.systemPackages = [ strata ];
}

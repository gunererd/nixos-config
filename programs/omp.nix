{ config, pkgs, lib, ... }:

let
  omp = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "omp";
    version = "17.2.7";

    src = pkgs.fetchurl {
      url = "https://github.com/can1357/oh-my-pi/releases/download/v${finalAttrs.version}/omp-linux-x64";
      hash = "sha256-bjgsgLCvWAFrD1N7YEo6KfHpEEq7SYcFKVNB44+9x3Q=";
    };

    dontUnpack = true;
    dontStrip = true;

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib pkgs.zlib ];

    installPhase = ''
      runHook preInstall
      install -Dm755 $src $out/bin/omp
      runHook postInstall
    '';

    meta = {
      description = "oh-my-pi (omp): terminal coding agent with the IDE wired in";
      homepage = "https://omp.sh";
      license = lib.licenses.mit;
      mainProgram = "omp";
      platforms = [ "x86_64-linux" ];
    };
  });
in
{
  environment.systemPackages = [ omp ];
}

{ config, pkgs, lib, ... }:

let
  username = "hippo";
  proxyPort = 43117;
  proxyUrl = "http://127.0.0.1:${toString proxyPort}";
  caPath = "/home/${username}/.llmtrim/ca.pem";

  llmtrim = pkgs.rustPlatform.buildRustPackage {
    pname = "llmtrim";
    version = "0.11.13-unstable-2026-07-28";

    src = pkgs.fetchFromGitHub {
      owner = "fkiene";
      repo = "llmtrim";
      rev = "0e0a123284db747ecad30d069d6b1136a0d2dbd7";
      hash = "sha256-lUrPdXWGc0iGgJbIawJgXISZdAmUVWlYf9uX2ISxakk=";
    };

    cargoHash = "sha256-x7sWSuY3cBHOtv20jukbBe7tUO/UtS2T0kq0HQLUfKU=";
    cargoBuildFlags = [ "-p" "llmtrim" ];
    doCheck = false;

    meta.mainProgram = "llmtrim";
  };
in
{
  environment.systemPackages = [ llmtrim ];

  systemd.services.llmtrim = {
    description = "llmtrim LLM request compressor proxy";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    environment = {
      LLMTRIM_BIND = "127.0.0.1";
      LLMTRIM_PRESET = "auto";
    };
    serviceConfig = {
      ExecStart = "${lib.getExe llmtrim} serve --supervised --port ${toString proxyPort}";
      User = username;
      Restart = "on-failure";
      RestartSec = 2;
    };
  };

  programs.fish.interactiveShellInit = ''
    if test -e ${caPath}
      set -gx HTTPS_PROXY ${proxyUrl}
      set -gx https_proxy ${proxyUrl}
      set -gx HTTP_PROXY ${proxyUrl}
      set -gx http_proxy ${proxyUrl}
      set -gx NODE_EXTRA_CA_CERTS ${caPath}
      set -gx CURL_CA_BUNDLE ${caPath}
      set -gx GIT_SSL_CAINFO ${caPath}
    end
  '';
}

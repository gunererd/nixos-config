{ config, pkgs, ... }:

let
  username = "hippo";
  home = "/home/${username}";
  node = pkgs.nodejs;

  gsdCore = pkgs.stdenvNoCC.mkDerivation {
    pname = "gsd-core";
    version = "1.9.1";
    src = pkgs.fetchurl {
      url = "https://registry.npmjs.org/@opengsd/gsd-core/-/gsd-core-1.9.1.tgz";
      hash = "sha256-BR69bZuVQweSLXVCkX/fn9+zrE6H6I3NJK90BeI3N1k=";
    };
    dontBuild = true;
    dontConfigure = true;
    installPhase = ''
      mkdir -p $out
      cp -r . $out/
    '';
  };
in
{
  environment.systemPackages = [ node ];

  system.activationScripts.gsdCoreInstall = {
    deps = [ "users" ];
    text = ''
      claudeDir="${home}/.claude"
      stage="${home}/.cache/gsd-core-src"
      mkdir -p "$claudeDir"

      rm -rf "$stage"
      mkdir -p "$stage"
      cp -r ${gsdCore}/. "$stage/"
      chmod -R u+w "$stage"

      HOME="${home}" CLAUDE_CONFIG_DIR="$claudeDir" \
        ${node}/bin/node "$stage/bin/install.js" --claude --global >/dev/null 2>&1 || true

      settings="$claudeDir/settings.json"
      if [ -f "$settings" ]; then
        ${pkgs.jq}/bin/jq '
          if .hooks.SessionStart then
            .hooks.SessionStart = [
              .hooks.SessionStart[]
              | .hooks = [ .hooks[] | select((.command // "") | test("gsd-check-update") | not) ]
              | select((.hooks | length) > 0)
            ]
          else . end
        ' "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"
      fi

      chown -R ${username}:users "$claudeDir" "$stage" 2>/dev/null || true
    '';
  };
}

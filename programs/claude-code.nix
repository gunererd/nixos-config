{ config, pkgs, ... }:

let
  username = "hippo";
  home = "/home/${username}";
  sounds = "${home}/nixos-config/sounds";
  permCmd = "pw-play ${sounds}/combeep0.wav >/dev/null 2>&1 &";
  stopCmd = "pw-play ${sounds}/tscupd00.wav >/dev/null 2>&1 &";
in
{
  environment.systemPackages = with pkgs; [
    claude-code
  ];

  system.activationScripts.claudeHooks = {
    deps = [ "users" ];
    text = ''
      claudeDir="${home}/.claude"
      settings="$claudeDir/settings.json"

      mkdir -p "$claudeDir"
      [ -f "$settings" ] || echo '{}' > "$settings"

      ${pkgs.jq}/bin/jq \
        --arg permCmd ${pkgs.lib.escapeShellArg permCmd} \
        --arg stopCmd ${pkgs.lib.escapeShellArg stopCmd} '
        .hooks.PermissionRequest = (.hooks.PermissionRequest // [])
        | if any(.hooks.PermissionRequest[]?; .hooks[]?.command == $permCmd)
          then . else .hooks.PermissionRequest += [{ hooks: [{ type: "command", command: $permCmd, async: true }] }] end
        | .hooks.Stop = (.hooks.Stop // [])
        | if any(.hooks.Stop[]?; .hooks[]?.command == $stopCmd)
          then . else .hooks.Stop += [{ hooks: [{ type: "command", command: $stopCmd, async: true }] }] end
      ' "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"

      chown -R ${username}:users "$claudeDir" 2>/dev/null || true
    '';
  };
}

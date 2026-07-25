{ config, pkgs, ... }:

let
  username = "hippo";
  home = "/home/${username}";
  rtkDotfiles = "${home}/nixos-config/dotfiles/common/rtk";
in
{
  environment.systemPackages = with pkgs; [
    rtk
  ];

  system.activationScripts.rtkInit = {
    deps = [ "users" ];
    text = ''
      claudeDir="${home}/.claude"
      opencodePlugins="${home}/.config/opencode/plugins"
      rtkConfig="${home}/.config/rtk"

      mkdir -p "$claudeDir" "$opencodePlugins" "$rtkConfig"

      ln -sfn "${rtkDotfiles}/RTK.md" "$claudeDir/RTK.md"
      ln -sfn "${rtkDotfiles}/opencode-plugin.ts" "$opencodePlugins/rtk.ts"
      ln -sfn "${rtkDotfiles}/filters.toml" "$rtkConfig/filters.toml"

      if [ ! -e "$claudeDir/CLAUDE.md" ] || ! ${pkgs.gnugrep}/bin/grep -qxF '@RTK.md' "$claudeDir/CLAUDE.md"; then
        echo '@RTK.md' >> "$claudeDir/CLAUDE.md"
      fi

      settings="$claudeDir/settings.json"
      [ -f "$settings" ] || echo '{}' > "$settings"
      ${pkgs.jq}/bin/jq '
        .hooks.PreToolUse = (.hooks.PreToolUse // [])
        | if any(.hooks.PreToolUse[]; .hooks[]?.command == "rtk hook claude")
          then .
          else .hooks.PreToolUse += [{
            matcher: "Bash",
            hooks: [{ type: "command", command: "rtk hook claude" }]
          }]
          end
      ' "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"

      chown -R ${username}:users "$claudeDir" "${home}/.config/opencode" "$rtkConfig" 2>/dev/null || true
    '';
  };
}

{ pkgs, ... }:

let
  username = "hippo";
  home = "/home/${username}";
  claudeDotfiles = "${home}/nixos-config/dotfiles/common/claude";
in
{
  system.activationScripts.ponytailInit = {
    deps = [ "users" ];
    text = ''
      claudeDir="${home}/.claude"
      commandsDir="$claudeDir/commands"

      mkdir -p "$commandsDir"

      ln -sfn "${claudeDotfiles}/ponytail.md" "$claudeDir/ponytail.md"

      for toml in ${claudeDotfiles}/commands/*.toml; do
        ln -sfn "$toml" "$commandsDir/$(${pkgs.coreutils}/bin/basename "$toml")"
      done

      if ! ${pkgs.gnugrep}/bin/grep -qxF '@ponytail.md' "$claudeDir/CLAUDE.md" 2>/dev/null; then
        echo '@ponytail.md' >> "$claudeDir/CLAUDE.md"
      fi

      chown -R ${username}:users "$claudeDir" 2>/dev/null || true
    '';
  };
}

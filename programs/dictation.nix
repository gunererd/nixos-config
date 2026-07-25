{ config, pkgs, ... }:

let
  username = "hippo";
  keyFile = "/home/${username}/.config/dictation/gemini.key";

  # English dictation runs locally on whisper.cpp (base.en, fetched at build
  # time so nothing downloads at runtime). Turkish goes to the Gemini API,
  # which handles Turkish-with-English code-switching far better than any model
  # this laptop can run offline.
  model = pkgs.fetchurl {
    url = "https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin";
    sha256 = "00nhqqvgwyl9zgyy7vk9i3n017q2wlncp5p7ymsk0cpkdp47jdx0";
  };

  geminiModel = "gemini-3.5-flash-lite";
  geminiPrompt = "Transcribe this audio verbatim. The speaker mixes Turkish and English. Keep English words and technical terms in normal English spelling (for example: commit, push, pull request, merge, deploy, refactor, branch, component, database). Transcribe Turkish speech in Turkish. Output only the transcription text, with no quotes, labels, or explanations.";

  # Shared toggle skeleton: first press records the mic, second press stops and
  # hands the recording to `transcribe` (a shell snippet that reads "$audio" and
  # sets "$text"). runtimeInputs must cover whatever `transcribe` calls.
  mkDictate = { name, label, runtimeInputs, transcribe }: pkgs.writeShellApplication {
    inherit name runtimeInputs;
    text = ''
      dir="''${XDG_RUNTIME_DIR:-/tmp}/${name}"
      mkdir -p "$dir"
      audio="$dir/rec.wav"
      pidfile="$dir/rec.pid"

      if [ -f "$pidfile" ] && kill -0 "$(cat "$pidfile")" 2>/dev/null; then
        pid="$(cat "$pidfile")"
        rm -f "$pidfile"
        kill -INT "$pid" 2>/dev/null || true
        for _ in $(seq 1 50); do
          kill -0 "$pid" 2>/dev/null || break
          sleep 0.1
        done
        text=""
        ${transcribe}
        if [ -n "$text" ]; then
          wtype "$text"
        else
          notify-send -t 1500 "Dictation" "No speech detected"
        fi
      else
        notify-send -t 1000 "Dictation" "🎙 Listening (${label})… press again to stop"
        ffmpeg -y -f pulse -i default -ar 16000 -ac 1 "$audio" >/dev/null 2>&1 &
        echo "$!" > "$pidfile"
      fi
    '';
  };

  english = mkDictate {
    name = "dictate-toggle";
    label = "EN";
    runtimeInputs = with pkgs; [ ffmpeg whisper-cpp wtype libnotify coreutils ];
    transcribe = ''
      notify-send -t 1500 "Dictation" "Transcribing…"
      text="$(whisper-cli -m ${model} -f "$audio" -nt -np 2>/dev/null \
        | tr '\n' ' ' | tr -s ' ' | sed -e 's/^ *//' -e 's/ *$//')"
    '';
  };

  turkish = mkDictate {
    name = "dictate-turkish";
    label = "TR";
    runtimeInputs = with pkgs; [ ffmpeg curl jq wtype libnotify coreutils ];
    transcribe = ''
      keyfile="${keyFile}"
      if [ ! -s "$keyfile" ]; then
        notify-send -u critical "Dictation" "Missing API key: $keyfile"
        exit 1
      fi
      key="$(tr -d '[:space:]' < "$keyfile")"

      notify-send -t 1500 "Dictation" "Transcribing (Gemini)…"
      base64 -w0 "$audio" | tr -d '\n' > "$dir/audio.b64"
      jq -n --arg p "${geminiPrompt}" --rawfile a "$dir/audio.b64" \
        '{contents:[{parts:[{text:$p},{inlineData:{mimeType:"audio/wav",data:$a}}]}],generationConfig:{temperature:0}}' \
        > "$dir/req.json"

      resp="$(curl -sS -m 30 -X POST \
        -H "x-goog-api-key: $key" -H 'Content-Type: application/json' \
        'https://generativelanguage.googleapis.com/v1beta/models/${geminiModel}:generateContent' \
        --data-binary @"$dir/req.json")"
      rm -f "$dir/audio.b64" "$dir/req.json"

      text="$(jq -r '.candidates[0].content.parts[0].text // empty' <<<"$resp" \
        | tr '\n' ' ' | sed -e 's/^ *//' -e 's/ *$//')"
      if [ -z "$text" ]; then
        err="$(jq -r '.error.message // "no text returned"' <<<"$resp")"
        notify-send -u critical "Dictation" "Gemini: $err"
      fi
    '';
  };
in
{
  environment.systemPackages = [ english turkish ];
}

# Flutter dev environment template

Per-project Flutter + Android toolchain via a Nix devShell. Tools appear only
inside a project folder, never system-wide.

## New app

```fish
flutter create my_app
cp templates/flutter/flake.nix templates/flutter/.envrc my_app/
cd my_app
direnv allow      # first load builds the toolchain, cached after
flutter doctor
```

`flutter`, `dart`, `adb` and the Android SDK are on PATH inside the folder and
gone when you `cd` out. Global tools are untouched.

## Devices

Plug in a device (USB debugging on) and `flutter run`. Emulator is off by default;
enable in `flake.nix` with `includeEmulator = true; includeSystemImages = true;`
plus `systemImageTypes`/`abiVersions`.

Versions are pinned in `flake.nix` (`buildToolsVersion`, `ndkVersion`,
`platformVersions`) — bump per project.

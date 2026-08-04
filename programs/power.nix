{ lib, pkgs, ... }:

{
  # s2idle wake sources: USB HID devices and every hub above them ship with
  # power/wakeup=disabled, so only the lid wakes the machine. Arm the HID leaf
  # (keyboards/mice) and every hub in the chain so typing/moving wakes it.
  services.udev.extraRules = ''
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="03", RUN+="${pkgs.runtimeShell} -c 'echo enabled > /sys%p/../power/wakeup'"
    ACTION=="add|change", SUBSYSTEM=="usb", ATTR{bDeviceClass}=="09", ATTR{power/wakeup}="enabled"
  '';

  # TLP replaces power-profiles-daemon (mutually exclusive). Noctalia's
  # power-profile widget stops working; TLP auto-switches on AC/battery.
  services.power-profiles-daemon.enable = lib.mkForce false;

  services.thermald.enable = true;

  # PSR lets the panel self-refresh static content without waking the
  # display pipe; drop enable_psr if it causes flicker on this panel.
  boot.kernelParams = [ "i915.enable_fbc=1" "i915.enable_psr=1" ];
  boot.kernel.sysctl."kernel.nmi_watchdog" = 0;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      PLATFORM_PROFILE_ON_AC = "low-power";
      PLATFORM_PROFILE_ON_BAT = "low-power";

      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";

      PCIE_ASPM_ON_AC = "default";
      PCIE_ASPM_ON_BAT = "powersupersave";

      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";

      USB_AUTOSUSPEND = 1;

      # Charge thresholds (ThinkPad natacpi) for battery longevity.
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };
}

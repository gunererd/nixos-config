{ lib, ... }:

{
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
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;

      PLATFORM_PROFILE_ON_AC = "performance";
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

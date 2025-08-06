{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # System monitoring and analysis
    procs         # Better ps command
    bottom        # Better htop/top (alternative to btop)
    dust          # Better du command
    bandwhich     # Network usage per process
    
    # Network utilities
    nmap          # Network discovery and security auditing
    wireshark     # Network protocol analyzer
    
    # Additional network tools that complement the above
    iftop         # Display bandwidth usage on interface
    nethogs       # Net traffic per process
    tcpdump       # Network packet analyzer
  ];

  # Enable wireshark for non-root users
  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  # Add user to wireshark group for packet capture
  users.users.hippo.extraGroups = [ "wireshark" ];
}
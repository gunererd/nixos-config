{ config, pkgs, ... }:

{
  # System-wide fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # Convert home.packages to system packages
  environment.systemPackages = with pkgs; [
    # Core system utilities
    tree
    wget
    curl
    unzip
    zip
    xwallpaper
    
    # Network utilities
    mtr
    nmap
    
    # Archive utilities
    p7zip
    
    # System monitoring
    neofetch
    btop

    # CLI tools
    eza        # Better ls
    bat        # Better cat
    fd         # Better find
    ripgrep    # Better grep
    zoxide     # Better cd
    fzf        # Fuzzy finder
  ];
  
  # System-wide font configuration
  fonts.fontconfig.enable = true;
} 
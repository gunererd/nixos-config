{ config, pkgs, ... }:

{
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
    atuin
    direnv
    jq         # JSON processor
    httpie     # HTTP client
    
    # Backend development tools
    ctop       # Container monitoring
    lazydocker # Docker terminal UI
    just       # Command runner
    air        # Go live reload
    
    # GUI tools
  ];
} 

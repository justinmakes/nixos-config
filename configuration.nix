# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nut.nix
      ./suckless.nix
      #./lutris.nix
    ];

  nixpkgs.config.allowUnfree = true; # required for nvidia drivers

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # point bootloader to partition containing luks (nvme0n1p2)
  boot.initrd.luks.devices = {
    root = {
      device = "/dev/disk/by-uuid/07129496-ae5d-4ec3-9ace-d99e45e60650";
      allowDiscards = true; # allow TRIM requests to the underlying device
    };
  };

  # systemd-logind
  services.logind = {
    killUserProcesses = true;
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore"; # behavior when another screen is added.
    lidSwitchExternalPower = "ignore"; # behavior when system is on external power.
  };

  # Filesystem options
  # btrfs autoScrub
  services.btrfs = {
    autoScrub.enable = true;
    autoScrub.interval = "monthly";
  };
  swapDevices = [ { device = "/.swap/swapfile"; } ];

  # VM guest settings
  #services.spice-vdagentd.enable = true;
  #services.qemuGuest = {
  #  enable = true;
  #  # package = pkgs.qemu_kvm.ga # this is default value!
  #};

  # Virtualization - Libvirtd
  programs.dconf.enable = true;
  virtualisation.libvirtd = {
    enable = true;
    #package = pkgs.libvirt;
    #allowedBridges = [ "virbr0" ];
    #extraConfig = ""; # extra contents of libvirtd.conf
    #extraOptions = [ "--verbose" ]; # command line arguments e.g. "--verbose"
    #onBoot = "start";
    #onShutdown = "suspend"; # suspend will attempt to save the state of the guests on host shutdown
    qemu = {
      #package = pkgs.qemu;
      ovmf = {
        #enable = true;
        #packages = [ pkgs.OVMF.fd ];
      };
      runAsRoot = false; # default true
      #swtpm = {};
      #verbatimConfig = ""; # contents written to qemu.conf
    };
  };

  # Laptop power management
  powerManagement = {
    enable = true;
    #cpuFreqGovernor = ""; # ondemand/powersave/performance
    #cpufreq.max = <integer>;
    #cpufreq.min = <integer>;
    #powerDownCommands = ""; # Commands executed when on shutdown/suspend/hibernate. Use strings concatenated with "\n"
    #powertop.enable = false;
    #powerUpCommands = "";
    #resumeCommands = "";
    #scsiLinkPolicy = "max_performance";
  };

  networking = {
    interfaces.enp0s13f0u1u3.ipv4.addresses = [ {
      address = "192.168.1.31";
      prefixLength = 24;
    } ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];
    enableIPv6 = false;
    hostName = "oryp8"; # Define your hostname.

    # Pick only one of the below networking options.
    wireless.enable = false;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    # Configure network proxy if necessary
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  # Set your time zone.
  time.timeZone = "America/Phoenix";


  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    
    displayManager = {
      startx.enable = true;
    };

    windowManager.awesome = {
      enable = true;
      luaModules = with pkgs.luaPackages; [
        luarocks # is the package manager for Lua modules
        luadbi-mysql # Database abstraction layer
      ];
    };
  };
  services.xserver.autorun = false;

  # GPU Drivers: Optimus Laptop Config
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  #hardware.opengl.driSupport32Bit = true; # Seems to cause screen flickering on nvidia card. Proton seems to work fine without it.
  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    prime.sync.enable = true; # nvidia driver always on
    prime.offload.enable = false; # Mutually exclusive with sync mode, will prioritize integrated gpu.
    #powerManagement.enable = false;
    prime.nvidiaBusId = "PCI:1:0:0";
    prime.intelBusId = "PCI:0:2:0";
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS and AVAHI for network printing.
  services.avahi.enable = true;
  services.avahi.openFirewall = true;
  services.avahi.nssmdns = true;
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };

  # Enable sound.
  # rtkit is optional but recommended
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput = {
    enable = true;
    #mouse.accelProfile = "flat";
    #mouse.accelSpeed = "-1";
    #mouse.dev = "/dev/input/by-id/usb-Ploopy_Corporation_Trackball-if02-event-mouse"
    #mouse.naturalScrolling = false;
    #mouse.transformationMatrix = "1.0 0 0 0 1.0 0 0 0 1.00"

    # see 'man libinput' for available options:
    #mouse.additionalOptions = ''
    #  Option "DragLockButtons"\n
    #  Option AccelProfile "flat"\n
    #  Option AccelSpeed -1\n
    #  '';
  };

  # See source code at: https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/security/sudo.nix
  security.sudo = {
    enable = true;
    # extraRules = [
    #   "Defaults:justinr timestamp_timeout=60"
    # ];
  };

  # set default interactive shell
  programs.zsh = {
    enable = true;
    enableBashCompletion = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    autosuggestions.async = true;
    syntaxHighlighting.enable = true;

  };
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  fonts.fonts = with pkgs; [
    dina-font
    fira # Provides "Fira Sans" to doomemacs
    fira-code # Provides "Fira Code" to doomemacs
    fira-code-symbols
    liberation_ttf
    mplus-outline-fonts.githubRelease
    nerdfonts
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    proggyfonts
  ];

  xdg.mime = {
    enable = true;
    addedAssociations = { };
    defaultApplications = {
      "text/mml" = "qutebrowser.desktop";
      "text/xml" = "qutebrowser.desktop";
      "text/html" = "qutebrowser.desktop";
      "x-scheme-handler/http" = "qutebrowser.desktop";
      "x-scheme-handler/https" = "qutebrowser.desktop";
      "x-scheme-handler/about" = "qutebrowser.desktop";
      "x-scheme-handler/unknown" = "qutebrowser.desktop";
      "x-scheme-handler/sidequest=SideQuest.desktop";
      #"application/pdf" = "zathura.desktop";
      #"x-scheme-handler/mailto" = "mu.desktop";
      #"application/x-krita" = "org.kde.krita.desktop";
      #"x-scheme-handler/magnet" = "rtorrent.desktop";
    };
    removedAssociations = {
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "x-scheme-handler/about" = "firefox.desktop";
      "x-scheme-handler/unknown" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-kde
    ];
    lxqt.enable = true;
    wlr.enable = true;
  };

  # Steam - unfree
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.justinr = {
    isNormalUser = true;
    home = "/home/justinr";
    shell = pkgs.zsh;
    uid = 1000;
    extraGroups = [ "audio" "libvirtd" "networkmanager" "wheel" ]; # Enable ‘sudo’ for the user.
    # openssh.authorizedKeys.keys = [ "ssh-dss AAAAB3Nza... alice@foobar" ];
    packages = with pkgs; [
      bc
      blender
      discord # unfree
      feh
      #fractal # Matrix client written in rust
      gnucash
      godot
      hplip
      imagemagick
      isync
      libreoffice
      looking-glass-client # GPU Passthrough without an external monitor!
      lutris
      monado # open source xr runtime
      mpv
      mu
      #mupdf
      ncspot
      newsboat
      nyxt
      pass
      pulsemixer
      qutebrowser
      ranger
      rofi
      rofi-pass
      sidequest
      sxiv
      ueberzug
      youtube-dl
      xclip
      zathura
    ];
  };

  # Automatically run nix garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    alacritty
    clang
    clippy # rust code linter
    cmake
    coreutils
    curl
    #direnv # Run 'nix develop' automatically when you cd into project directory (autoloads nix environment)
    emacs
    emacsPackages.async
    emacsPackages.elfeed
    emacsPackages.helm
    emacsPackages.magit
    emacsPackages.mpv
    emacsPackages.org
    emacsPackages.org-roam
    emacsPackages.ranger
    emacsPackages.ripgrep
    emacsPackages.sqlite3
    emacsPackages.tramp
    emacsPackages.tree-sitter
    emacsPackages.treemacs
    emacsPackages.treeview
    emacsPackages.vterm
    fd # file indexer, improves performance in doom emacs
    gcc
    git
    git-crypt
    gnumake
    htop
    lua
    man
    neofetch
    #nix-direnv # helps with caching for 'direnv'
    pciutils
    pinentry
    polkit
    python3
    ripgrep
    rust-analyzer # rust language server
    rustfmt # rust code formatter
    rustup # rust toolchain installer
    sbcl
    spacevim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    sshfs
    sumneko-lua-language-server
    system76-firmware
    system76-keyboard-configurator # allows you to customize laptop keyboard as well!
    tldr
    unzip
    usbutils
    virt-manager
    # wget
    wine
    winetricks
    wine-staging
    wine-wayland
    zsh-nix-shell
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # List services that you want to enable:

  # Redshift
  location = {
    latitude = 33.4483771;
    longitude = -112.0740373;
  };
  services.redshift = {
    enable = true;
    package = pkgs.redshift;
    #executable = "/run/current-system/sw/bin/redshift"; # default is "/bin/redshift"
    temperature.day = 5500;
    temperature.night = 2000;
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "no";

  # Crypto Support
  services.trezord.enable = true;

  # Emacs Daemon
  services.emacs = {
    enable = true;
    package = pkgs.emacs;
    defaultEditor = true; # set emacsclient as the default editor using the EDITOR environment variable.
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?

}


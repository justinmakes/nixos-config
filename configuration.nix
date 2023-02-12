# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nut.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  #boot.loader.grub.device = "/dev/disk/by-uuid/991eacbb-8530-4766-a2e2-4c44592b9212"; # or "nodev" for efi only
  boot.loader.grub.devices = [ "/dev/sda" "/dev/sdb" "/dev/sdc" "/dev/sdd" ];
  
  fileSystems = {
    "/" = {
      #device = "/dev/disk/by-uuid/991eacbb-8530-4766-a2e2-4c44592b9212";
      device = "/dev/sda1";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "subvolid=257" ];
    };
    "/home" = {
      #device = "/dev/disk/by-uuid/991eacbb-8530-4766-a2e2-4c44592b9212";
      device = "/dev/sda1";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "subvolid=258" ];
    };
    "/swap" = {
      #device = "/dev/disk/by-uuid/991eacbb-8530-4766-a2e2-4c44592b9212";
      device = "/dev/sda1";
      fsType = "btrfs";
      options = [ "defaults" "noatime" "subvolid=259" ];
    };
  };

  services.btrfs.autoScrub.enable = true;
  services.btrfs.autoScrub.interval = "monthly";

  # UPS config
  #power.ups = {
  #  enable = false;
  #};

  # Networking
  networking = {
    interfaces.enp2s0.ipv4.addresses = [ {
      address = "192.168.1.41";
      prefixLength = 24;
    } ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];
    enableIPv6 = false;
    hostName = "srv-nas";

    # Pick only one of the below networking options.
    # wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    networkmanager.enable = true; # Easiest to use and most distros use this by default.

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
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = {
  #   "eurosign:e";
  #   "caps:escape" # map caps to escape.
  # };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  
  # set default shell
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

  # set environment variables
  environment.variables = {
    EDITOR = "spacevim";
    VISUAL = "spacevim";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.justinr = {
    isNormalUser = true;
    home = "/home/justinr";
    shell = pkgs.zsh;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      #firefox
      #thunderbird
    ];
  };

  # Automatically run nix garbage collection
  nix.gc.automatic = true;
  nix.gc.dates = "weekly";

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    git
    ranger
    sshfs
    spacevim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #wget
    zsh-nix-shell
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  #services.openssh.permitRootLogin = "no";

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

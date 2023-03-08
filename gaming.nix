{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lutris
    (lutris.override {
      extraLibraries =  pkgs: [
        # List library dependencies here
      ];
    })
    (lutris.override {
       extraPkgs = pkgs: [
         # List package dependencies here
         pkgs.libnghttp2 # fix for lutris curl error: https://github.com/NixOS/nixpkgs/issues/214375#issuecomment-1454978126
           # NOTE: Make sure you delete ~/.local/share/lutris
       ];
    })
    mangohud
  ];

  # StarCitizen Lutris EAC workaround:
  networking.extraHosts =
    ''
      127.0.0.1 modules-cdn.eac-prod.on.epicgames.com
    '';

  # Steam - unfree
  hardware.steam-hardware.enable = true; # Required for steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';

  systemd.user.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';
}

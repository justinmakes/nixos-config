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
         curl
         #pkgs.nghttp2
       ];
    })
  ];

  systemd.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';

  systemd.user.extraConfig = ''
    DefaultLimitNOFILE=1048576
  '';
}

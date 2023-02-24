{ config, pkgs, ... }:
let
  my-emacs-packages = p: with p; [
    gdscript-mode
    # other emacs packages
  ];
in {
  environment.systemPackages = [
    (pkgs.emacs.withPackages my-emacs-packages)
  ];
}

# NOTE: 'emacs' does not have the 'withPackages' property!

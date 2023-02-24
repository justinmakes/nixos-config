{ config, pkgs, ... }:
let
  my-emacs-packages = p: with p; [
    gdscript-mode
    pipenv
    # other emacs packages
  ];
in {
  environment.systemPackages = [
    (pkgs.emacs.withPackages my-emacs-packages)
  ];
}

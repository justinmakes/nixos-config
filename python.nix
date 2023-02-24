{ config, pkgs, ... }:
let
  my-python-packages = p: with p; [
    #gdtoolkit
    isort
    nose
    #pip # required by gdtoolkit
    pygame
    pytest
    setuptools
    # other python packages
  ];
in {
  environment.systemPackages = [
    (pkgs.python3.withPackages my-python-packages)
  ];
}

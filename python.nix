{ config, pkgs, ... }:
let
  my-python-packages = p: with p; [
    isort
    nose
    pytest
    setuptools
    # other python packages
  ];
in {
  environment.systemPackages = [
    (pkgs.python3.withPackages my-python-packages)
  ];
}

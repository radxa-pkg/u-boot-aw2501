{ pkgs, lib, config, ... }:

{
  packages = with pkgs; [
    powershell
  ];
}

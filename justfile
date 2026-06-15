#!/usr/bin/env -S just --justfile
# Justfile for common tasks.

repo-id := 'nixsys'


[private]
default: help


# Remove result/ and other artifacts.
clean:
    rm -f ./result *.qcow2 *-efi-vars.fd


# Show this help and exit.
help:
    @just --list --list-prefix $'{{BOLD}}{{BLUE}}→{{NORMAL}} ' --justfile {{justfile()}} --list-heading $'{{BOLD}}{{CYAN}}◉ {{YELLOW}}{{repo-id}}{{CYAN}} dev console{{NORMAL}}\n'


# Build a home config.
[arg('name', pattern='headless')]
build-home name="headless":
    home-manager build --flake {{justfile_directory()}}#{{name}}


# Build a machine config.
[arg('target', pattern='toplevel|vm|vmWithDisko')]
[arg('name', pattern='workstation')]
build-machine name target="vmWithDisko":
    nix build {{justfile_directory()}}#nixosConfigurations.{{name}}.config.system.build.{{target}}

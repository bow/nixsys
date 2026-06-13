from cyclopts import App

from . import init_flake, show_deps

app = App(name="nix", help="Nix-related wrappers")
app.command(init_flake.init_flake)
app.command(show_deps.show_deps)

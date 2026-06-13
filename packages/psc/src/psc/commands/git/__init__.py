from cyclopts import App

from . import clone_mirror

app = App(name="git", help="Git-related wrappers")
app.command(clone_mirror.clone_mirror)

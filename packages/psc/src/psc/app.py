import sys
from typing import Literal

from cyclopts import App, CycloptsError
from cyclopts.help import PlainFormatter
from rich.console import Console

from psc.commands import git, nix


console = Console()

app = App(
    name="psc",
    help_format="markdown",
    help_formatter=PlainFormatter(indent_width=2, max_width=120),
    console=console,
)

# Hide default 'commands'.
app["--version"].show = False
app["--help"].show = False

app.command(git.app)
app.command(nix.app)


def show_error(e: CycloptsError) -> None:
    console.print(
        f"[bold black on red] Error [/bold black on red] [default]{e}[/default]"
    )


# Set own completion command.
@app.command(name="--generate-completions", show=False)
def generate_completions(shell: Literal["bash"] = "bash") -> None:
    script = app.generate_completion(shell=shell)
    print(script)


def main() -> None:
    try:
        app()
    except CycloptsError as e:
        show_error(e)
        sys.exit(1)

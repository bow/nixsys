import shutil
import subprocess as sp
from pathlib import Path
from typing import Annotated

import pygraphviz as pgv
from cyclopts import Parameter, CycloptsError


def show_deps(
    input: Path | str,
    fg: str = "#f9f5d7",
    bg: str = "#427b58",
    force: Annotated[bool, Parameter(name=["--force", "-f"], negative=[])] = False,
) -> None:
    """Show runtime dependencies of a Nix store path.

    :param input: Executable name in $PATH or a filesystem path
    :param fg: Graph foreground color
    :param bg: Graph background color
    :param force: Toggle force drawing if the number of nodes exceeds the maximum

    """
    path = resolve_to_path(input)

    proc_nix_query = sp.check_output(["nix-store", "--query", "--graph", f"{path}"])
    gv_raw = proc_nix_query.decode("utf-8")

    graph = pgv.AGraph(string=gv_raw, directed=True)

    max_nodes = 75
    n_nodes = len(graph.nodes())
    if n_nodes > max_nodes and not force:
        raise CycloptsError(
            f"number of graph nodes {n_nodes} exceeds maximum allowed of {max_nodes};"
            " use -f/--force to render anyway"
        )

    for node in graph.nodes():
        node.attr["fontcolor"] = fg
        node.attr["color"] = bg
        node.attr["fillcolor"] = bg

    for edge in graph.edges():
        edge.attr["color"] = bg

    proc_png_export = sp.run(
        ["dot", "-Tpng"],
        input=f"{graph}".encode("utf-8"),
        stdout=sp.PIPE,
        check=True,
    )

    sp.run(["timg", "-"], input=proc_png_export.stdout, check=True)


def resolve_to_path(input: Path | str) -> Path:

    path = Path(input)
    if path.exists():
        if path.parts[:3] == ("/", "nix", "store"):
            return path

        path = path.resolve()
        if path.parts[:3] == ("/", "nix", "store"):
            return path

        raise CycloptsError(f"input {input} is not in the nix store")

    path = Path(shutil.which(input))
    if path is None:
        raise CycloptsError(f"input {input} not found in $PATH")

    path = path.resolve()
    if path.parts[:3] == ("/", "nix", "store"):
        return path

    raise CycloptsError(f"input {input} does not resolve to the nix store")

import subprocess as sp


def init_flake(
    template: str,
) -> None:
    """Initialize a template from https://github.com/bow/flates

    :param template: Template name

    """
    sp.check_call(["nix", "flake", "init", "-t", f"github:bow/flates#{template}"])

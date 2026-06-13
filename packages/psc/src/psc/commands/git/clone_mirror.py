import os
import subprocess as sp
from dataclasses import dataclass
from pathlib import Path
from typing import Self
from urllib.parse import urlsplit

from cyclopts import CycloptsError


MIRRORS_ROOT = Path.home() / "devel" / "mirrors"


def clone_mirror(
    spec: str,
) -> None:
    """Clone a repo into the ~/devel/mirrors/ tree.

    :param spec: Repository specifier.

    """
    if not MIRRORS_ROOT.exists():
        raise CycloptsError(f"mirrors root {MIRRORS_ROOT} not found")

    repo = Repo.from_spec(spec)

    groups_dir = MIRRORS_ROOT / repo.site / "/".join(repo.groups)
    repo_dir = groups_dir / repo.name

    if repo_dir.exists():
        print(f"Repo already exists at {repo_dir}")
        return None

    os.makedirs(groups_dir, exist_ok=True)
    sp.check_call(["git", "clone", f"{repo.url}", repo_dir])

    print(f"Cloned {repo.url} to {repo_dir}")

    return None


@dataclass
class Repo:
    url: str
    site: str
    groups: list[str]
    name: str

    @classmethod
    def from_spec(cls, spec: str) -> Self:
        # e.g. https://github.com/{group}/{name}
        if spec.startswith("https://") or spec.startswith("http://"):
            return cls._from_url(spec)

        # e.g. github.com/{group}/{name}
        if any(
            spec.startswith(prefix)
            for prefix in ("github.com/", "codeberg.org/", "git.sr.ht/")
        ):
            spec = f"https://{spec}"
            return cls._from_url(spec)

        # e.g. github:{group}/{name}
        if any(
            spec.startswith(prefix) for prefix in ("github:", "codeberg:", "sourcehut:")
        ):
            return cls._from_repo_shorthand(spec)

        raise CycloptsError(f"{spec!r} is an unsupported repo spec")

    @classmethod
    def _from_repo_shorthand(cls, shorthand: str) -> Self:
        service, rem = shorthand.split(":", 1)

        match service:
            case "github":
                return cls._from_url(f"https://github.com/{rem}")
            case "codeberg":
                return cls._from_url(f"https://codeberg.org/{rem}")
            case "sourcehut":
                return cls._from_url(f"https://git.sr.ht/~{rem}")
            case _:
                raise CycloptsError(f"{service!r} is an unsupported repo spec")

    @classmethod
    def _from_url(cls, url: str) -> Self:
        res = urlsplit(url)

        site = res.netloc

        path = res.path.strip("/")
        if not path:
            raise CycloptsError(f"resolved repo URL {url} has no subpath")
        if "/" not in path:
            raise CycloptsError(f"resolved repo URL {url} has no group and/or name")

        parents, name = path.rsplit("/", 1)

        if site == "git.sr.ht" and parents.startswith("~"):
            parents = parents[1:]

        groups = parents.split("/")

        return Repo(url, site, groups, name)

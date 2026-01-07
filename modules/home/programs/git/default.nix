{
  config,
  lib,
  pkgs,
  user,
  options,
  ...
}:
let
  cfg = config.nixsys.home.programs.git;
in
{
  options.nixsys.home.programs.git = {
    enable = lib.mkEnableOption "nixsys.home.programs.git";
    inherit (options.programs.git) package;
  };

  config = lib.mkIf cfg.enable {

    programs.git = {
      enable = true;

      settings = {

        user = {
          inherit (user) email;
          name = user.full-name;
        };
        core = {
          autocrlf = "input";
          safecrlf = "warn";
          editor = "nvim";
        };
        branch = {
          sort = "-committerdate";
        };
        commit = {
          verbose = true;
        };
        diff = {
          algorithm = "histogram";
          colorMoved = "plain";
          compactionHeuristic = true;
          mnemonicprefix = true;
          renames = true;
        };
        fetch = {
          prune = true;
          pruneTags = true;
          all = true;
        };
        init = {
          defaultBranch = "master";
        };
        push = {
          default = "simple";
          autoSetupRemote = true;
          followTags = true;
        };
        rebase = {
          autosquash = true;
          autoStash = true;
          updateRefs = true;
        };
        rerere = {
          enabled = true;
          autoupdate = true;
        };
        tag = {
          sort = "version:refname";
        };
        color = {
          ui = "auto";
        };
        alias = {
          # list all alias
          lsalias = "!${cfg.package}/bin/git config -l | ${pkgs.gnugrep}/bin/grep alias | cut -c 7-";

          # basic shortcuts
          co = "checkout";
          ci = "commit";
          cp = "cherry-pick";
          st = "status";
          br = "branch";
          mg = "merge";
          sh = "stash";
          wt = "worktree";

          # various commit displays
          hist = "log --pretty=format:'%C(yellow)%h %Cblue%ad %Creset• %s%C(red)%d%Creset %C(cyan)[%an • %G?]%Creset' --graph --date=short";
          histh = "log --pretty=format:'%C(yellow)%h %Cblue%cr %Creset• %s%C(red)%d%Creset %C(cyan)[%an • %G?]%Creset' --graph --abbrev-commit --";
          histf = "log --pretty=format:'%C(yellow)%h %Cblue%cr %Creset• %s%C(red)%d%Creset %C(cyan)[%cn • %G?]' --decorate --numstat";
          histo = "log --format=format:'%C(yellow)%h %Creset• %<(50,trunc)%s %C(cyan)[%cN • %G?] %C(blue)%cr%Creset %Cred%d' --graph -20 --branches --remotes --tags --date-order";
          histb = ''!f() { ${cfg.package}/bin/git log --pretty=format:'%C(yellow)%h %Cblue%cr %Creset• %s%C(red)%d%Creset %C(cyan)[%an • %G?]%Creset' --graph --abbrev-commit ''${1:-''$(${cfg.package}/bin/git rev-parse --abbrev-ref HEAD)} --not ''${2:-master}; }; f'';
          histp = "log -u";

          # handy aliases
          adp = "add -p";
          ec = "config --global -e";
          cia = "commit --amend";
          ciam = "commit --no-edit --amend";
          stn = "status -uno";
          difc = "diff --cached";
          diffc = "diff --cached";
          punch = "push -f";
          rsh = "reset -q HEAD --";
          discard = "checkout --";
          uncommit = "reset --mixed HEAD~";
          syncr = "fetch --all --prune";
          shi = "stash --staged";
          shl = "stash list";
          shs = ''!f() { ${cfg.package}/bin/git stash show -p stash@{''${1:-0}}; }; f'';
          shp = ''!f() { ${cfg.package}/bin/git stash pop stash@{''${1:-0}}; }; f'';
          shd = ''!f() { ${cfg.package}/bin/git stash drop stash@{''${1:-0}}; }; f'';
          ed = ''!f() { ${cfg.package}/bin/git rebase -i HEAD~''${1:-''$(${cfg.package}/bin/git rev-list --left-right --count ''$(${cfg.package}/bin/git rev-parse --abbrev-ref ''$(${cfg.package}/bin/git rev-parse --abbrev-ref HEAD)@{upstream})...''$(${cfg.package}/bin/git branch --show-current) | cut -f2)}; }; f'';
          brstat = "for-each-ref --sort=-committerdate refs/heads/ --format='%(color:yellow)%(objectname:short)%(color:reset) %(color:blue)%(committerdate:short)%(color:reset) • %(color:red)(%(refname:short))%(color:reset) %(contents:subject) %(color:cyan)[%(authorname)]%(color:reset)'";
          up = ''!${cfg.package}/bin/git pull --rebase --prune ''$@ && ${cfg.package}/bin/git submodule update --init --recursive'';
          linediff = ''!f() { ${cfg.package}/bin/git diff --numstat --pretty ''${1} | ${pkgs.gawk}/bin/awk '{ print $1+$2"\t"$0 }' | sort -nrk1,1; }; f'';
          clinediff = ''!f() { ${cfg.package}/bin/git diff --numstat --pretty ''${1} | ${pkgs.gawk}/bin/awk '{ if (!($1 ~ /0/ || $2 ~ /0/ || ($1+$2) ~ /0/)) print $1+$2"\t"$0 }' | sort -nrk1,1; }; f'';

          # assume / unassume changed
          assume = "update-index --assume-unchanged";
          unassume = "update-index --no-assume-unchanged";
          # show assumed files
          assumed = "!${cfg.package}/bin/git ls-files -v | ${pkgs.gnugrep}/bin/grep ^h | cut -c 3-";
          # unassume / assume all
          unassumeall = "!${cfg.package}/bin/git assumed | ${pkgs.findutils}/bin/xargs ${cfg.package}/bin/git update-index --no-assume-unchanged";
          assumeall = "!${cfg.package}/bin/git st -s | ${pkgs.gawk}/bin/awk {'print $2'} | ${pkgs.findutils}/bin/xargs ${cfg.package}/bin/git assume";
        };
      };

      includes = lib.mkAfter [
        { path = "${user.home-directory}/.config/git/local"; }
      ];

      ignores = [
        # Local dev
        ".direnv"
        ".env"
        ".envrc-private"
        ".ignore"
        ".tool-versions"
        "sandbox"

        # C/C++
        ".ccls"

        # Python
        "*.pyc"
        "*.pyo"
        "*.egg-info"
        ".cache"
        ".coverage"
        ".coverage.*"
        ".eggs"
        ".dmypy.json"
        ".ipynb_checkpoints/"
        ".mypy_cache"
        ".tox"
        ".pytest_cache"
        ".python-version"
        ".venv"
        "htmlcov"
        "test.py"
        "venv"

        # Rust
        "tarpaulin-report.html"

        # Java
        ".settings/"
        ".project"
        ".classpath"

        # JavaScript
        ".node-version"
        ".nvmrc"
        "node_modules"

        # R
        "*.RData"
        "*.RHistory"
        "*.Rout"

        # Ruby
        ".rspec"

        # Scala
        "test.sc"

        # Compiled
        "*.class"
        "*.dll"
        "*.exe"
        "*.o"
        "*.so"

        # SQLite
        "*.sqlite"
        "test.db"

        # Vim
        "*.swp"
        "*.swo"

        # IntelliJ
        "*.iml"
        ".idea"

        # Archives
        "*.7z"
        "*.dmg"
        "*.gz"
        "*.iso"
        "*.jar"
        "*.rar"
        "*.tar"
        "*.zip"

        # OS-specific
        ".DS_Store"
        "ehthumbs.db"
        "Icon?"
        "Thumbs.db"

        # Misc
        ".luarc.json"
        "*.log"
        ".scannerwork"
        ".~lock.*"
        "*.sif"
        ".evans.toml"
        ".todo"
        ".bak"
        ".tdst.toml"
        ".vagrant"
        ".null-ls*"
      ];
    };
  };
}

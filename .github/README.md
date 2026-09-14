# dotfiles -- syncing config files with a Git bare repository

English | [简体中文](README.zh-CN.md)

Reference articles:

- Atlassian: <https://www.atlassian.com/git/tutorials/dotfiles>
- Medium (Daryl Galvez): <https://jinjinir.medium.com/dotfiles-management-using-git-bare-repositories-2453c435c700>

## How it works

A **Git bare repository** lives at `$HOME/.dotfiles`, and its **work-tree is
`$HOME` itself**. Files such as `~/.zshrc`, `~/.gitconfig` and `~/.config/**`
stay exactly where they are and are still under version control:

- No extra tooling (chezmoi / stow / yadm) -- `git` alone is enough;
- No symlinks -- every config file stays where the system expects it;
- A shell alias (`dotfiles_git` below) pins `--git-dir` / `--work-tree`, so this
  repository never interferes with the ordinary git repositories under `$HOME`;
- Everything git gives you for free: history, diffs, reverts, branches (one per
  machine if you like), and one-command restore on a new box after pushing to a
  private GitHub repository.

The essential setting is `status.showUntrackedFiles = no`. `$HOME` holds
thousands of files; with untracked files hidden, `dotfiles_git status` only ever
reports the files you **explicitly added**. The trade-off: new files are never
suggested to you, so you must run `dotfiles_git add <file>` yourself.

## Layout

The repository root *is* `$HOME`, so a path in the repository maps directly onto
the real path under your home directory -- there is no separate "repo copy" and
"deployed copy".

```
$HOME/                              ← work-tree (= repository root)
├── .dotfiles/                      ← the bare repository (GIT_DIR), git internals only
│   ├── HEAD
│   ├── config                      ← core.bare / status.showUntrackedFiles / remote / user
│   ├── objects/
│   └── refs/
│
├── .github/                        ← docs (GitHub renders the README found here)
│   ├── README.md                   ← English, shown on the repository home page
│   └── README.zh-CN.md             ← Chinese
│
├── .claude/
│   └── ...
│
├── .config/                        ← one directory per program, e.g.:
│   ├── ghostty/
│   ├── nvim/
│   └── ...
│
├── Documents/                      ← untracked home files never show up in status
└── ...
```

Two things worth noting:

- `.dotfiles/` is git's own data directory, not a config file -- **never add it**.
- The docs live in `.github/` rather than the repository root: GitHub looks for a
  README in `.github/`, the root, and `docs/` (in that order of precedence), so
  `.github/` gets it rendered on the home page without leaving a conspicuous
  `~/README.md` in the home directory. See
  [About the repository README file](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-readmes):

  > If you put your README file in your repository's hidden `.github`, root, or
  > `docs` directory, GitHub will recognize and automatically surface your README
  > to repository visitors.

## Key commands

### 1. First-time setup on this machine

```sh
git init --bare --initial-branch=master $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no
```

### 2. Define the alias

```sh
alias dotfiles_git='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo "alias dotfiles_git='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> $HOME/.zshrc

dotfiles_git config --local user.name  TODO
dotfiles_git config --local user.email TODO
```


### 3. Everyday use (replace `git` with `dotfiles_git`)

```sh
dotfiles_git status
dotfiles_git add .zshrc .gitconfig .p10k.zsh
dotfiles_git commit -m "Add zsh and git config"
dotfiles_git log --oneline
dotfiles_git diff
dotfiles_git push
```

### 4. Add the remote (prefer a **private** repository -- config files often carry keys and internal paths)

```sh
dotfiles_git remote add origin git@github.com:<user>/<repo>.git
dotfiles_git push -u origin master
```

### 5. Restore on a new machine

```sh
# In the source repository, ignore the bare repo directory itself to avoid recursion
echo ".dotfiles" >> $HOME/.gitignore   # then: dotfiles_git add .gitignore && commit

# On the new machine:
alias dotfiles_git='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:<user>/<repo>.git $HOME/.dotfiles
dotfiles_git checkout
dotfiles_git config --local status.showUntrackedFiles no
```

If `dotfiles_git checkout` fails with
`error: The following untracked working tree files would be overwritten by checkout:`,
the new system already ships its own copies of those files. Back them up and
retry (the script from the Atlassian article):

```sh
mkdir -p .dotfiles-backup && \
dotfiles_git checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .dotfiles-backup/{}
dotfiles_git checkout
```

### 6. Other common operations

```sh
dotfiles_git rm --cached <file>          # stop tracking, keep the local file
dotfiles_git checkout -- <file>          # discard local edits, restore the committed version
dotfiles_git pull                        # pick up the latest config on another machine
dotfiles_git status -u -- <dir>          # list untracked files under <dir> (never bare in $HOME)
```

## Caveats

- **Never commit secrets**: `~/.ssh/id_*`, a token-bearing `.npmrc` / `.netrc` /
  `.aws/credentials`, and the like.
- Never run `dotfiles_git add .` -- the work-tree is the whole of `$HOME`. Add
  specific files and directories only.

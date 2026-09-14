# dotfiles -- 用 Git 裸仓库同步配置文件

[English](README.md) | 简体中文

参考文章：

- Atlassian：<https://www.atlassian.com/git/tutorials/dotfiles>
- Medium（Daryl Galvez）：<https://jinjinir.medium.com/dotfiles-management-using-git-bare-repositories-2453c435c700>

## 方案简述

把一个 **Git 裸仓库（bare repository）** 放在 `$HOME/.dotfiles`，让它的
**工作区（work-tree）直接就是 `$HOME`**。这样 `~/.zshrc`、`~/.gitconfig`、
`~/.config/**` 等文件留在原地就能被版本管理：

- 不需要额外工具（chezmoi / stow / yadm），只要有 `git`；
- 不需要软链接，配置文件仍在系统期望的位置；
- 通过一个 shell alias（下称 `dotfiles_git`）把 `--git-dir` / `--work-tree` 固定住，
  因此不会和 `$HOME` 下其它普通 git 仓库互相干扰；
- 天然拥有 git 的全部能力：历史、diff、回滚、分支（可为不同机器开不同分支）、
  推到 GitHub 私有库后在新机器上一条命令还原。

关键点是 `status.showUntrackedFiles = no`：`$HOME` 下有成千上万个文件，
关掉未跟踪文件显示后，`dotfiles_git status` 只会显示你**显式 add 过**的文件。
代价是新文件不会自动提醒，必须手动 `dotfiles_git add <file>`。

## 目录结构

仓库根目录就是 `$HOME`，所以仓库里的路径直接对应家目录下的真实路径，
不存在"仓库目录"和"部署位置"的区分。

```
$HOME/                              ← work-tree（= 仓库根目录）
├── .dotfiles/                      ← 裸仓库本体（GIT_DIR），只有 git 内部数据
│   ├── HEAD
│   ├── config                      ← core.bare / status.showUntrackedFiles / remote / user
│   ├── objects/
│   └── refs/
│
├── .github/                        ← 文档（GitHub 会自动渲染这里的 README）
│   ├── README.md                   ← 英文，显示在仓库首页
│   └── README.zh-CN.md             ← 中文（本文件）
│
├── .claude/
│   └── ...
│
├── .config/                        ← 按程序分子目录，例如：
│   ├── ghostty/
│   ├── nvim/
│   └── ...
│
├── Documents/                      ← 未跟踪的家目录文件不会出现在 status 里
└── ...
```

两点值得留意：

- `.dotfiles/` 是 git 的数据目录，不是配置文件，**不要 add 它**。
- 文档放在 `.github/` 而不是仓库根目录：GitHub 会在 `.github/`、根目录、`docs/`
  三处查找 README（优先级也是这个顺序），放 `.github/` 既能在首页渲染，
  又不会在家目录里多出一个显眼的 `~/README.md`。

## 关键命令

### 1. 本机初始化

```sh
git init --bare --initial-branch=master $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles --work-tree=$HOME config --local status.showUntrackedFiles no
```

### 2. 定义 alias

```sh
alias dotfiles_git='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
echo "alias dotfiles_git='/usr/bin/git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> $HOME/.zshrc

dotfiles_git config --local user.name  TODO
dotfiles_git config --local user.email TODO
```


### 3. 日常使用（把 `git` 换成 `dotfiles_git`）

```sh
dotfiles_git status
dotfiles_git add .zshrc .gitconfig .p10k.zsh
dotfiles_git commit -m "Add zsh and git config"
dotfiles_git log --oneline
dotfiles_git diff
dotfiles_git push
```

### 4. 关联远程（建议用**私有**仓库，配置里常有密钥/路径等敏感信息）

```sh
dotfiles_git remote add origin git@github.com:<user>/<repo>.git
dotfiles_git push -u origin master
```

### 5. 在新机器上还原

```sh
# 先在源仓库里忽略裸仓库目录自身，避免递归
echo ".dotfiles" >> $HOME/.gitignore   # 然后 dotfiles_git add .gitignore && commit

# 新机器：
alias dotfiles_git='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:<user>/<repo>.git $HOME/.dotfiles
dotfiles_git checkout
dotfiles_git config --local status.showUntrackedFiles no
```

`dotfiles_git checkout` 若报错
`error: The following untracked working tree files would be overwritten by checkout:`，
说明新系统已存在同名的默认配置。备份后重试（Atlassian 原文给的脚本）：

```sh
mkdir -p .dotfiles-backup && \
dotfiles_git checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
xargs -I{} mv {} .dotfiles-backup/{}
dotfiles_git checkout
```

### 6. 其它常用操作

```sh
dotfiles_git rm --cached <file>          # 停止跟踪但保留本地文件
dotfiles_git checkout -- <file>          # 丢弃本地改动，恢复到已提交版本
dotfiles_git pull                        # 在另一台机器上同步最新配置
dotfiles_git status -u -- <dir>          # 查看 <dir> 下还有哪些未跟踪文件（别在 $HOME 裸跑）
```

## 注意事项

- **不要提交密钥**：`~/.ssh/id_*`、带 token 的 `.npmrc` / `.netrc` / `.aws/credentials` 等。
- 不要 `dotfiles_git add .`（工作区是整个 `$HOME`），只按文件/目录精确 add。

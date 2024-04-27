# Install: Dotfiles

![macOS](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/macos.svg)
![Linux](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/linux.svg)

Dotfiles covering Bash, Vim, tmux, and Git—compatible with macOS and Linux.

![Bash](https://github.com/weibeld-setup/.github/blob/main/img/logos/bash-small.png)&nbsp;&nbsp;&nbsp;&nbsp;
![Vim](https://github.com/weibeld-setup/.github/blob/main/img/logos/vim-small.png)&nbsp;&nbsp;&nbsp;&nbsp;
![tmux](https://github.com/weibeld-setup/.github/blob/main/img/logos/tmux-small.png)&nbsp;&nbsp;&nbsp;&nbsp;
![Git](https://github.com/weibeld-setup/.github/blob/main/img/logos/git-small.png)&nbsp;&nbsp;&nbsp;&nbsp;

## Installation

![macOS](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/macos.svg)
![Linux](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/linux.svg)

To install the dotfiles, run the [`install.sh`](install.sh) script:

```bash
bash <(curl https://raw.githubusercontent.com/weibeld-setup/install-dotfiles/master/.dotfiles.info/install.sh)
```

> **Note:** see [_Installation method_](#installation-method) for an explanation of how the dotfiles are installed. In the case of name conflicts with existing files, the script presents multiple resolution options.

To cleanly uninstall the dotfiles, run the [`uninstall.sh`](uninstall.sh) script:

```bash
bash <(curl https://raw.githubusercontent.com/weibeld-setup/install-dotfiles/master/.dotfiles.info/uninstall.sh)
```

## Usage

![macOS](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/macos.svg)
![Linux](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/linux.svg)

To manage the installed dotfiles through the dotfiles Git repository, use the `df` alias just like the `git` command:

```bash
df status
df add FILE
df commit
df push
df pull
```

The `df` alias can be used as-is from any working directory of the system.

> **Note:** to manage the Git submodules in the dotfiles repository, see [_Git submodules and Vim plugins_](#git-submodules-and-vim-plugins).

### Background

The dotfiles repository is installed as a [bare Git repository](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server) in `$HOME/.dotfiles.git` with the workspace directory in `$HOME` (that is, the dotfiles themselves are checked out to `$HOME`).

The `df` alias is defined in [`.bashrc.main`](../.bashrc.main) as follows:

```bash
git --git-dir="$HOME"/.dotfiles.git --work-tree="$HOME"
```

That means, the `df` command is essentially a `git` command where the location of the Git repository directory (`$HOME/.dotfiles.git`) and the workspace directory (`$HOME`) are explicitly specified (which is required for bare Git repositories).

## Notes

### Installation method

The [`install.sh`](install.sh) script clones this repository as a [bare Git repository](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server) to **`$HOME/.dotfiles.git`** and checks out the dotfiles to **`$HOME`**.

That means that, after installation, the dotfiles repository exists a bare Git repository with:

- The **repository directory** in **`$HOME/.dotfiles.git`**
- The **workspace directory** in **`$HOME`**

> **Note:** `$HOME` is the home directory of the user who executes the `install.sh` script.

The **repository directory** is the directory where the internal Git repository files reside. The **workspace directory** is the directory where the repository files are checked out and tracked.

This installation method allows managing the installed dotfiles directly in the dotfiles Git repository, without any exports/imports, symlinks, etc.

> **Note:** see [_Frequently asked questions (FAQ)_](#frequently-asked-questions-faq) for more information about bare Git repositories, and why a bare Git repository is used.

### Git submodules and Vim plugins

The dotfiles repository has full support for [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) (that is, the inclusion of other Git repositories within a Git repository).

Currently, Git submodules are only used for [Vim plugins](https://www.vim.org/scripts/), which in turn are managed by [vim-plug](https://github.com/junegunn/vim-plug).

The following lists the most important operations for managing Vim plugins:

1. [Listing all submodules and Vim plugins](#listing-all-submodules-and-vim-plugins)
1. [Adding a new Vim plugin](#adding-a-new-vim-plugin)
1. [Deleting an existing Vim plugin](#deleting-an-existing-vim-plugin)
1. [Updating an installed Vim plugin](#updating-an-installed-vim-plugin)

> **Note:** documentation for vim-plug can be found in the vim-plug's [README](https://github.com/junegunn/vim-plug) as well as in its [wiki](https://github.com/junegunn/vim-plug/wiki).

#### Listing all submodules and Vim plugins

To list all submodules in the dotfiles repository, run the following command:

```bash
df submodule status
```

To specifically list all Vim plugins from within Vim, run the following vim-plug command:

```vim
:PlugStatus
```

#### Adding a new Vim plugin

1. Declare the plugin in the [`.vimrc.plugins`](.vimrc.plugins) file according to the [vim-plug syntax](https://github.com/junegunn/vim-plug/wiki/tutorial#installing-plugins)
1. Reload the `.vimrc` file (`:source ~/.vimrc`) or restart Vim
1. Install the plugin with the following vim-plug command:
   ```vim
   :PlugInstall
   ```
   > **Note:** the above command clones the Git repository of the Vim plugin into a subdirectory of `$HOME/.vim/plugged`.
1. Add the cloned Vim plugin Git repository as a submodule to the dotfiles repository:
   ```bash
   df -C "$HOME" submodule add <repo-url> .vim/plugged/<plugin-dir>
   ```
   > **Note:** `<repo-url>` is the URL of the Vim plugin Git repository and `<plugin-dir>` is the subdirectory of `$HOME/.vim/plugged` that was created by the `:PlugInstall` command above.
1. Commit all changes
   ```bash
   df add ...
   df commit
   ```

#### Deleting an existing Vim plugin

1. Delete the declaration of the plugin in [`.vimrc.plugins`](.vimrc.plugins)
1. Delete the submodule corresponding to the Vim plugin:
   ```bash
   df rm <submodule-path>
   ```
   > **Note:** `<submodule-path>` is the path of the submodule corresponding to the Vim plugin as displayed by `df submodule status` (a subdirectory of `$HOME/.vim/plugged`).
1. Commit all changes:
   ```bash
   df add ...
   df commit
   ```

#### Updating an installed Vim plugin 

1. Run the following vim-plug command:
   ```vim
   :PlugUpdate [<plugin-name>]
   ```
   > **Note:** `<plugin-name>` is the name of the plugin as displayed by `:PlugStatus`. If `<plugin-name>` is omitted, then all installed Vim plugins are updated.
1. Commit all changes:
   ```bash
   df add ...
   df commit
   ```

### Frequently asked questions (FAQ)

#### What is a bare Git repository?

A [bare Git repository](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server) is a repository in which the repository directory (the directory holding the internal Git repository files) is decoupled from the workspace directory (which is where the files of the repository are checked out and tracked).

This differs from a normal repository in which the repository directory is a directory named `.git` at the top level of the workspace directory.

The following illustration summarises this distinction:

```
Normal repository:
+--------------------------------+
| .git/             Workspace    |
| +------------+    directory    |
| | Repository |                 |
| | directory  |                 |
| |            |                 |
| +------------+                 |
+--------------------------------+

Bare repository:
+--------------+  +--------------+  
| Repository   |  | Workspace    |  
| directory    |  | directory    |  
|              |  |              |  
|              |  |              |
|              |  |              |  
|              |  |              |  
+--------------+  +--------------+  
```

#### Why the dotfiles are installed as a bare Git repository?

Installing the dotfiles as a bare Git repository allows checking out the files into an existing directory (in this case, the user's `$HOME` directory), without modifying the existing content of this directory.

This is required for installing dotfiles, as the task is to add additional files (i.e. the dotfiles) to the existing `$HOME` directory. The dotfiles can't be in some other directory because `$HOME` is where the various tools look for dotfiles by convention.

This wouldn't be possible with a normal repository, as a normal repository always involves creating a new workspace directory that can't have pre-existing content.

# Install: Dotfiles

![macOS](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/macos.svg)
![Linux](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/linux.svg)

Dotfiles repository with support for Git submodules.

## Installation

![macOS](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/macos.svg)
![Linux](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/linux.svg)

Run the [`install.sh`](.dotfiles.info/install.sh) script anywhere on the system:

```bash
curl -s https://raw.githubusercontent.com/weibeld-setup/install-dotfiles/master/.dotfiles.info/install.sh >install.sh
chmod +x install.sh
./install.sh
```

The above commands install the dotfiles into the home directory of the executing user.

> **Note:** if there are name conflicts with existing files, the `install.sh` script provides a dialog with options for handling this case.

## Uninstallation

Run the [`uninstall.sh`](.dotfiles.info/uninstall.sh) script anywhere on the system:

```bash
curl -s https://raw.githubusercontent.com/weibeld-setup/install-dotfiles/master/.dotfiles.info/uninstall.sh >install.sh
chmod +x uninstall.sh
./uninstall.sh
```

## Notes

### Installation method

The dotfiles repository is installed as a **bare Git repository** with:

- The **repository directory** in **`$HOME/.dotfiles.git`**
- The **workspace directory** in **`$HOME`**

> **Note:** `$HOME` is the home directory of the user who executes the `install.sh` script.

The repository directory is the directory where the internal Git repository files reside, and the workspace directory is the directory where the repository files are checked out and tracked.

See [_Frequently asked questions (FAQ)_](#frequently-asked-questions-faq) for more information about bare Git repositories, and why a bare Git repository is used.

### Usage

The use of a bare Git repository requires specifying the location of both the repository directory and the workspace directory to Git.

This can be done as follows:

```bash
git --git-dir="$HOME"/.dotfiles.git --work-tree="$HOME"
```

The [`.bashrc.main`](../.bashrc.main) file in this repository defines the alias `df` for exactly that command:

```bash
alias df='git --git-dir="$HOME"/.dotfiles.git --work-tree="$HOME"'
```

This alias is the recommended way to interact with the dotfiles repository. It can be used in a similar way as the `git` command on its own, for example:

```bash
df status
df add FILE
df commit
df push
df pull
```

> **Note:** thanks to the fact that all paths are explicitly declared in the alias command, the above alias can be used from **anywhere on the system**.

### Submodule usage

The dotfiles repository has full support for [Git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) (that is, the inclusion of other Git repositories within a Git repository).

In the dotfiles repository, submodules are currently only used for [Vim plugins](https://www.vim.org/scripts/), which are in turn managed by [vim-plug](https://github.com/junegunn/vim-plug).

The following lists the most important operations for Vim plugins:

1. [Listing all submodules (Vim plugins)](#listing-all-submodules-vim-plugins)
1. [Adding a new Vim plugin](#adding-a-new-vim-plugin)
1. [Deleting an existing Vim plugin](#deleting-an-existing-vim-plugin)
1. [Updating an installed Vim plugin](#updating-an-installed-vim-plugin)

> **Note:** documentation for vim-plug can be found in the project's [README](https://github.com/junegunn/vim-plug) as well as in the [wiki](https://github.com/junegunn/vim-plug/wiki).

#### Listing all submodules (Vim plugins)

To list all submodules in the dotfiles repository, run the following command:

```bash
df submodule status
```

To list all Vim plugins specifically from within Vim, run the following vim-plug command:

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
   > **Note:** the above clones the corresponding Vim plugin Git repository into a subdirectory of `$HOME/.vim/plugged`.
1. Add the cloned Vim plugin Git repository as a submodule to the dotfiles repository:
   ```bash
   df -C "$HOME" submodule add <repo-url> .vim/plugged/<plugin-dir>
   ```
   > **Note:** `<repo-url>` is the URL of the Vim plugin Git repository and `<plugin-dir>` is the subdirectory of `$HOME/.vim/plugged` that was created by the vim-plug command above.
1. Commit all changes
   ```bash
   df add ...
   df commit
   ```

#### Deleting an existing Vim plugin

1. Delete the declaration of the plugin in [`.vimrc.plugins`](.vimrc.plugins)
1. Delete the submodule:
   ```bash
   df rm <submodule-path>
   ```
   > **Note:** `<submodule-path>` is the path of the coresonding submodule as displayed by `df submodule status` (in the case of a Vim plugin, it's a subdirectory of `$HOME/.vim/plugged`).
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
   > **Note:** `<plugin-name>` is the name of the plugin as displayed by `:PlugStatus`. If `<plugin-name>` is omitted, then all installed plugins are updated.
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

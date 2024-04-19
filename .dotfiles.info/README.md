# Install: Dotfiles

![macOS](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/macos.svg)
![Linux](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/linux.svg)

Dotfiles repository with support for Git submodules.

## Installation

![macOS](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/macos.svg)
![Linux](https://raw.githubusercontent.com/weibeld-setup/.github/main/badge/linux.svg)

Run the [`install.sh`](.dotfiles.info/install.sh) script with Bash from anywhere on the system:

```bash
curl -s https://raw.githubusercontent.com/weibeld-setup/install-dotfiles/master/.dotfiles.info/install.sh >install.sh
chmod +x install.sh
./install.sh
```

> **Note:** if there are name conflicts with existing files on the system, the `install.sh` script pauses and prompts you to back up these files before proceeding. Any local files and directories in the `$HOME` directory with the same name as a file or directory in this repository will be deleted and replaced by the version from this repository.

## Notes

### Installation method

The dotfiles repository is installed as a [bare](https://git-scm.com/book/en/v2/Git-on-the-Server-Getting-Git-on-a-Server) Git repository in `~/.dotfiles.git` with the workspace in the user's home directory (`~`).

A bare Git repository is a repository in which the Git directory (which is named `.git` in a non-bare repository) and the workspace directory (which is where files are checked out and tracked) are decoupled and may be located at different locations on the system.

Normal repository:

```
+------------------------+
| Workspace   .git       |
| directory   +-------+  |
|             | Git   |  |
|             | dir   |  |
|             +-------+  |
+------------------------+
```

Bare repository:

```
+--------------+   +--------------+
| Workspace    |   | Git          |
| directory    |   | directory    |
|              |   |              |
|              |   |              |
|              |   |              |
+--------------+   +--------------+
```

The above dotfiles installation method uses the following configuration:

| Directory           | Location          |
|:--------------------|:------------------|
| Git directory       | `~/.dotfiles.git` |
| Workspace directory | `~`               |

### Repository management

To interact with the dotfiles repository, the following Git command must be used:

```bash
git --git-dir="$HOME"/.dotfiles.git --work-tree="$HOME"
```

> **Note:** remember that the dotfiles repository is a bare Git repository in `~/.dotfiles.git` with the workspace in `~`.

To facilitate this, the [`.bashrc.main`](../.bashrc.main) file defines the following `df` alias:

```bash
alias df='git --git-dir="$HOME"/.dotfiles.git --work-tree="$HOME"'
```

This alias can be used from anywhere on the system to interact with the dotfiles repository, as if it was a normal Git repository.

For example:

```bash
df status
df add <file>
df commit
df push
df pull
```

### Submodule management

#### Adding a submodule

#### Removing a submodule

#### Updating a submodule



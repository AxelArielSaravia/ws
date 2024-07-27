# ws
version dev-2024-08
[![GLWTPL](https://img.shields.io/badge/GLWT-Public_License-red.svg)](https://github.com/me-shaon/GLWTPL)

**ws** is a tool to managing working directories, and simplify 'tmux sessions'.
Its always create a tmux session with 2 windows, one for a text editor like
neovim, and the other for normal terminal. 

This is a presonal tool, thats why is under a GLWT Plublic License.

It is only tested in fedora 39 but I think that must work on most of the linux
distributions.

### Installation

You must have installed:
- tmux

Copy the 'ws' file in '/usr/bin' directory

I recomended to copy the 'ws-completition.sh' file in to '/etc/bash_completion.d/'
directory for <Tab><Tab> autocompletitions (that was one of the points of
this tool).

Besides, I recomend to write the next lines of sh code in the
'.bash_profile' file to have a simple persistents tmux sessions.
```sh
ws init-tmux
```

### How to used

For a complete information see:
```sh
ws help
```
<br>

**ws** have the next commands:
    
    add  clear-history  dir  dirs  help  init-tmux  list
    names  open  remove  remove-all  tmux  version
    

Use ``add`` to create new or edit workspaces. For instance:
```sh
ws add myproject ~/Mydir/project/
```

Use ``open`` or ``tmux`` for open (and create) a tmux session (remember that the tmux
sessions created have 2 windows):
```sh
ws tmux myproject
```
You can add ``-tmux`` at the end of a ``add`` command to create a tmux
session when you create a workspace:
```sh
ws add myproject ~/Mydir/project/ -tmux
```

When you use ``remove``, its will kill the tmux session and delete the
workspace.
```sh
ws remove myproject
ws remove myproject -tmux #only kill the tmux session
ws remove myproject -ws #only delete the workspace
```

``list``, ``dirs`` and ``names`` returns worspace information.

If you only want to jump to a workspace, you can use: (it is a 'cd' wrapper)
```sh
ws go myproject
```

---

Axel Ariel Saravia

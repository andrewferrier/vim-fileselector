# vim-fileselector

This is a vim plugin which allows you to quickly open files from a variety of
sources using [fzf](https://github.com/junegunn/fzf) as a file selector. It is similar in spirit to
[fzf-z](https://github.com/andrewferrier/fzf-z), but operates on files, not
directories, and is a vim plugin, not a zsh plugin.

Currently it uses three sources:

1. The MRU (most recently used) files you've used in vim. `vim-fileselector`
   keeps track of that itself, so you don't need another plugin or list.

1. `git ls-files` (only works if you are currently inside a git repo).

1. `find` or `fd`.

Once installed, you need to configure a key to open the list, like this:

```
    nnoremap <silent> <Leader>e :MRUDisplay<CR>
```

## Installation

Like [any vim
plugin](https://vi.stackexchange.com/questions/613/how-do-i-install-a-plugin-in-vim-vi).

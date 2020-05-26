# vim-fileselector

This is a vim plugin which allows you to quickly open files from a variety of
sources using [fzf](https://github.com/junegunn/fzf) as a file selector. It is
similar in spirit to [fzf-z](https://github.com/andrewferrier/fzf-z), but
operates on files, not directories, and is a vim plugin, not a zsh plugin.

Requires Vim 8+ or NeoVim for pop-up window support.

## Installation

Ensure you have the [fzf vim plugin](https://github.com/junegunn/fzf.vim)
installed first.

Then, install this plugin like [any other vim
plugin](https://vi.stackexchange.com/questions/613/how-do-i-install-a-plugin-in-vim-vi).

Once installed, you need to configure a key to open the list, like this:

``` vim
    nnoremap <silent> <Leader>e :FileSelectorDisplay<CR>
```

## Understanding Sources of Files Shown

Currently it uses three sources:

1. The MRU (most recently used) files you've used in vim. `vim-fileselector`
   keeps track of that itself, so you don't need another plugin or list.

1. `git ls-files` (only works if you are currently inside a git repo).

1. `find` or `fd` - this is based off all files in a space-separated list of
   directories you specify in the `g:fileselector_extra_dirs` environment
   variable. For example:

``` vim
   let g:fileselector_extra_dirs = ['~/stuff', '/tmp']
```

If [highlight](https://www.gnu.org/software/src-highlite/) is installed,
`vim-fileselector` will use it highlight the file contents in the preview
window. If it's not, it will gracefully degrade to unhighlighted contents.

## Ways of Speeding Up vim-fileselector

`vim-fileselector` will run faster if
[ripgrep](https://github.com/BurntSushi/ripgrep) or
[fd](https://github.com/sharkdp/fd) and [GNU
grep](https://www.gnu.org/software/grep/) are available ([the latter is not
available by default on OS X](https://apple.stackexchange.com/a/193300)). It
will autodetect and use these tools if present.

## Other Configuration Options

You can set patterns for excluded files from being stored in
`vim-fileselector`'s MRU list:

```vim
let g:fileselector_exclude_pattern = ['.*\.pdf', '\.DS_Store']
```

All patterns are ORed together and evaluated using vim's own regex engine.

If you want to override the color scheme used by `highlight`, set for example
`HIGHLIGHT_OPTIONS="solarized-dark"` in your environment (see `man highlight`
for more information.

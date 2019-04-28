if exists('g:loaded_fileselector') || &compatible
    finish
endif
let g:loaded_fileselector=1

if !exists('g:fileselector_extra_dirs')
    let g:fileselector_extra_dirs=''
endif

if !exists('g:fileselector_exclude_pattern')
    let g:fileselector_exclude_pattern='/.git'
endif

let s:zeroending = "tr '\\n' '\\0'"
let s:relativeifier = "xargs -0 realpath --relative-base=$HOME | sed -e 's/^\\([^\\/]\\)/~\\/\\1/'"
let s:existence_check = "perl -ne 'print if -e substr(\$_, 0, -1);'"

let s:source_mru = "cat ~/.cache/ctrlp/mru/cache.txt | " . s:existence_check . " | " . s:zeroending
let s:source_git = "git ls-files -z"

if executable('fd')
    let s:source_find_prefix = 'fd --color=never --hidden --type file . '
    let s:source_find_postfix = ''
else
    let s:source_find_prefix = 'find '
    let s:source_find_postfix = ' -type f'
endif

if g:fileselector_extra_dirs != ''
    let s:source_find = s:source_find_prefix .
                \ g:fileselector_extra_dirs .
                \ s:source_find_postfix .
                \ " | egrep -v '" . g:fileselector_exclude_pattern . "' | " . s:zeroending
else
    let s:source_find = 'true'
endif

let s:deduplicator = "awk '!seen[$0]++'"

let s:sources = "{ " . s:source_mru . " ; " . s:source_git . " ; " . s:source_find . "; } 2>/dev/null | " . s:relativeifier . " | " . s:deduplicator

let s:preview = "echo {} | sed -e 's^~^$HOME^' | tr '\\n' '\\0' | xargs -0 head -\\$((\\$LINES-2))"

function! s:MRUDisplay()
    call fzf#run(fzf#wrap({'source': s:sources, 'options': '--tiebreak=index --preview="' . s:preview . '"'}))
endfunction

command! -bar MRUDisplay call <SID>MRUDisplay()

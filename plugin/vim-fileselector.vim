if exists('g:loaded_fileselector') || &compatible
    finish
endif
let g:loaded_fileselector=1

let s:source_mru = "cat ~/.cache/ctrlp/mru/cache.txt | perl -ne 'print if -e substr(\$_, 0, -1);'"
let s:source_git = "git ls-files"

if executable('fd')
    let s:source_find = 'fd --color=never --hidden --type=file .'
else
    let s:source_find = 'find . -type f'
endif

let s:relativeifier = "tr '\n' '\\0' | xargs -0 realpath"

let s:sources = "{ " . s:source_mru . " ; " . s:source_git . " ; " . s:source_find . "; } 2>/dev/null | " . s:relativeifier

function! s:MRUDisplay()
    call fzf#run(fzf#wrap({'source': s:sources, 'options': '--tiebreak=index --preview="head -100 {}"'}))
endfunction

command! -bar MRUDisplay call <SID>MRUDisplay()

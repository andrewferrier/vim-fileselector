if exists('g:loaded_fileselector') || &compatible
    finish
endif
let g:loaded_fileselector=1

if !exists('g:fileselector_extra_dirs')
    let g:fileselector_extra_dirs=''
endif

let s:existence_check = "perl -ne 'print if -e substr(\$_, 0, -1);'"

let s:source_mru = "cat ~/.cache/ctrlp/mru/cache.txt | " . s:existence_check
let s:source_git = "git ls-files"

if executable('fd')
    let s:source_find_prefix = 'fd --color=never --hidden . '
    let s:source_find_postfix = ' --type file'
else
    let s:source_find_prefix = 'find '
    let s:source_find_postfix = ' -type f'
endif

let s:relativeifier = "tr '\n' '\\0' | xargs -0 realpath"
if g:fileselector_extra_dirs != ''
    let s:source_find = s:source_find_prefix . g:fileselector_extra_dirs . s:source_find_postfix
else
    let s:source_find = 'true'
endif

let s:sources = "{ " . s:source_mru . " ; " . s:source_git . " ; " . s:source_find . "; } 2>/dev/null | " . s:relativeifier

function! s:MRUDisplay()
    call fzf#run(fzf#wrap({'source': s:sources, 'options': '--tiebreak=index --preview="head -100 {}"'}))
endfunction

command! -bar MRUDisplay call <SID>MRUDisplay()

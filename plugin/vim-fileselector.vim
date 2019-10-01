if exists('g:loaded_fileselector') || &compatible
    finish
endif

let g:loaded_fileselector=1

if !exists('g:fileselector_extra_dirs')
    let g:fileselector_extra_dirs=''
endif

if !exists('g:fileselector_exclude_pattern')
    let g:fileselector_exclude_pattern=['/.git']
endif

let s:mru_file_dir = $HOME . '/.cache/vim-fileselector'
let s:mru_file = s:mru_file_dir . '/mru'
let s:mru_max_length = 1000

" neovim doesn't need this guard, but vim will fail if the directory exists.
if !isdirectory(s:mru_file_dir)
    call mkdir(s:mru_file_dir, 'p')
endif

let s:mru_files = []

function! s:MRU_AddFile(bufnr_filetoadd) abort
    let l:fname = fnamemodify(bufname(a:bufnr_filetoadd + 0), ':p')
    if l:fname ==# '' || &buftype !=# ''
        return
    endif

    if g:fileselector_exclude_pattern !=# []
        if l:fname =~# join(g:fileselector_exclude_pattern, '\|')
            return
        endif
    endif

    let l:idx = index(s:mru_files, l:fname)
    if l:idx == -1 && !filereadable(l:fname)
        return
    endif

    if filereadable(s:mru_file)
        let s:mru_files = readfile(s:mru_file)
        if s:mru_files[0] =~# '^#'
            call remove(s:mru_files, 0)
        else
            let s:mru_files = []
        endif
    else
        let s:mru_files = []
    endif

    call filter(s:mru_files, 'v:val !=# l:fname')
    call insert(s:mru_files, l:fname, 0)

    if len(s:mru_files) > s:mru_max_length
        call remove(s:mru_files, s:mru_max_length, -1)
    endif

    let l:newlist = []
    call add(l:newlist, '# vim-fileselector - most recently used at the top')
    call extend(l:newlist, s:mru_files)
    call writefile(l:newlist, s:mru_file)
endfunction

augroup vim-fileselector
    autocmd BufRead * call s:MRU_AddFile(expand('<abuf>'))
    autocmd BufNewFile * call s:MRU_AddFile(expand('<abuf>'))
    autocmd BufWritePost * call s:MRU_AddFile(expand('<abuf>'))
augroup END

let s:zeroending = "tr '\\n' '\\0'"
let s:relativeifier = 'xargs -0 realpath --relative-base=$HOME'
let s:replace_with_tilde = "sed -e 's/^\\([^\\/]\\)/~\\/\\1/'"
let s:existence_check = "perl -ne 'print if -e substr(\$_, 0, -1);'"

let s:source_mru = 'cat ' . s:mru_file . ' | ' . s:existence_check . ' | ' . s:zeroending

" We use --no-ignore here because vim-fileselector may often be used to
" navigate source code bases; we may want to edit generated files etc.
" which may be gitignored.
if executable('rg')
    " From some informal benchmarking I've done, rg seems to be ~50% faster
    " than fd at this query.
    let s:source_find_prefix = 'rg --no-config --no-ignore --color=never --hidden --files '
    let s:source_find_postfix = ''
elseif executable('fd')
    let s:source_find_prefix = 'fd --no-ignore --color=never --hidden --type file . '
    let s:source_find_postfix = ''
else
    let s:source_find_prefix = 'find '
    let s:source_find_postfix = ' -type f'
endif

if executable('gegrep')
    let s:grep = 'gegrep'
else
    let s:grep = 'egrep'
endif

function! s:GetExcluder() abort
    return s:grep . " -v '" . join(g:fileselector_exclude_pattern, '|') . "'"
endfunction

if g:fileselector_extra_dirs !=# ''
    let s:source_find = s:source_find_prefix .
                \ g:fileselector_extra_dirs .
                \ s:source_find_postfix .
                \ ' | ' . s:GetExcluder() . ' | ' . s:zeroending
else
    let s:source_find = 'true'
endif

let s:source_git = 'git ls-files -z'

let s:source_extra = s:source_git . ' ; ' . s:source_find

if executable('locate')
    let s:output =  system('locate -S')
    if v:shell_error == 0
        let s:source_extra = 'locate --existing / | ' . s:GetExcluder() . ' | ' . s:zeroending
    endif
endif

if executable('fasd')
    let s:source_fasd = 'fasd -f -l -R | ' . s:zeroending
else
    let s:source_fasd = 'true'
endif

let s:deduplicator = "awk '!seen[$0]++'"

let s:sources = '{ ' . s:source_mru . ' ; ' . s:source_fasd . ' ; ' . s:source_extra . '; } 2>/dev/null | ' . s:relativeifier . ' | ' . s:replace_with_tilde . ' | ' . s:deduplicator

let s:highlight = ''

if executable('highlight')
    let s:output =  system('cat /dev/null | highlight --out-format=truecolor --syntax-by-name=c')

    if v:shell_error == 0
        let s:highlight = '| highlight --force --out-format=truecolor --syntax-by-name={}'
    endif
endif

let s:preview = "echo {} | sed -e 's^~^$HOME^' | " . s:zeroending . ' | xargs -0 -I"%" head -200 % ' . s:highlight

function! s:FileSelectorDisplay() abort
    call fzf#run(fzf#wrap({'source': s:sources, 'options': '--tiebreak=index --preview="' . s:preview . '"'}))
endfunction

command! -bar FileSelectorDisplay call <SID>FileSelectorDisplay()

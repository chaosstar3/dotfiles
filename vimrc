set nocompatible

function! TrimTrailingSpace()
	%s/\s\+$//e
endfunction
au BufWritePre    * :call TrimTrailingSpace()

" tab
noremap <C-n> :tabedit<CR>
let g:lasttab=1
noremap <C-w><C-w> :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab=tabpagenr()

" pane move
noremap <C-Left>  <C-w>h
noremap <C-Down>  <C-w>j
noremap <C-Up>    <C-w>k
noremap <C-Right> <C-w>l

" display
set t_Co=256
set bg=dark
au WinEnter * :hi StatusLine ctermfg=blue ctermbg=white

set nu
set list
set listchars=tab:>\ ,trail:\ ,
hi SpecialKey ctermfg=100 ctermbg=235

syntax on

set mouse=n
set noet sw=2 ts=2 sts=2
set eol

" include local rc
if filereadable(".vimrc.local")
	source .vimrc.local
endif


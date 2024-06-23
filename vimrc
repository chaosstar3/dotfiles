set nocompatible
set nomodeline
filetype off
filetype plugin indent off

if !empty(glob("~/.vim/autoload/plug.vim"))
call plug#begin('~/.vim/plugged')
" Edit
Plug 'vim-scripts/Smart-Tabs'
" UI
Plug 'nathanaelkane/vim-indent-guides'  " indent guide
	let g:indent_guides_start_level = 2
	let g:indent_guides_enable_on_vim_startup = 1
	let g:indent_guides_auto_colors = 0
Plug 'kien/rainbow_parentheses.vim'
Plug 'airblade/vim-gitgutter'
	let g:gitgutter_enabled = 0
"Plug 'mhinz/vim-signify'
Plug 'romainl/vim-cool' " hlsearch auto off
Plug 'timakro/vim-yadi'
au BufRead * DetectIndent

" Syntax
Plug 'slim-template/vim-slim'     " slim
Plug 'kchmck/vim-coffee-script'   " coffee
Plug 'cakebaker/scss-syntax.vim'  " scss
Plug 'Keithbsmiley/tmux.vim'      " tmux.conf
Plug 'rust-lang/rust.vim'         " rust
Plug 'evanleck/vim-svelte'        " svelte

" Util
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install -all' }
Plug 'junegunn/fzf.vim'
	let g:fzf_layout = {'down': '~50%' }
Plug 'majutsushi/tagbar'
	let g:tagbar_left = 0
	let g:tagbar_vertical = 33
	let g:tagbar_width = 80
	let g:tagbar_compact = 1
	let g:tagbar_indent = 0
Plug 'dhruvasagar/vim-zoom'
	let g:zoom#statustext = 'zoom'

call plug#end()
"else
"curl -fLo ~/.vim/autoload/plug.vim --create-dirs\
"	 https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" cscope
set cscopetag
set csto=0
set cst
set nocsverb
cs add cscope.out
set csverb


""" command & shortcuts
inoremap <C-w> <esc><C-w>

" tab
noremap <C-n> :tabedit<CR>
let g:lasttab=1
noremap <C-w><C-w> :exe "tabn ".g:lasttab<CR>
au TabLeave * let g:lasttab=tabpagenr()
nmap <C-w>Q :tabclose<CR>

" window
noremap <C-Left>  <C-w>h
noremap <C-Down>  <C-w>j
noremap <C-Up>    <C-w>k
noremap <C-Right> <C-w>l

" cscope
nnoremap <C-x>x <C-x>
nmap <C-x> <nop>
" symbol / definition / called / calling / egrep / assign
nmap <C-x>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-x>g :cs find g <C-R>=expand("<cword>")<CR><CR>
nmap <C-x>c :cs find c <C-R>=expand("<cword>")<CR><CR>
nmap <C-x>d :cs find d <C-R>=expand("<cword>")<CR><CR>
nmap <C-x>e :cs find e <C-R>=expand("<cword>")<CR><CR>
nmap <C-x>t :cs find t <C-R>=expand("<cword>")<CR><CR>

" Plugin
nmap <C-w>t :TagbarOpen fjc<CR>
nmap <C-w>g :GitGutterToggle<CR>
nmap <C-w>z <Plug>(zoom-toggle)

if has_key(get(g:, 'plugs', {}), 'fzf.vim')
	if executable("rg")
		command! CtrlP call fzf#run(fzf#wrap({'source': 'rg --hidden --files'}))
		command! E call fzf#run(fzf#wrap({'source': 'rg --hidden --no-ignore --files'}))
	elseif executable("ag")
		command! CtrlP call fzf#run(fzf#wrap({'source': 'ag --hidden -g ""'}))
		command! E call fzf#run(fzf#wrap({'source': 'ag --hidden -u -g ""'}))
	else
		command! CtrlP GFiles
		command! E Files
	endif
	nmap <silent> <C-p> :CtrlP<CR>
endif

command W write


""" display
set nu
set list
set listchars=tab:▸\ ,
au BufWinEnter * match TrailWS /\s\+$/

" Statusline
function! SLStr(str)
	if getwinvar(winnr(), 'WinActive', 0) == 0
		return ''
	endif

	let mode = mode()
	let map = {
	\ 'N': ['n', 'no'],
	\ 'I': ['i', 'ic', 'ix'],
	\ 'V': ['v', 'V', "\<C-v>"],
	\}

	if a:str == '?'
		for [k, v] in items(map)
			for e in v
				if e == mode
					return ''
				end
			endfor
		endfor
		return mode.' '
	endif

	for m in get(map, a:str, 'other mode')
		if m == mode
			return ' '.a:str.' '
		endif
	endfor

	return ''
endfunction

function! GetStr(str, default, ...)
	if a:str == ''
		return a:default
	else
		let prefix = get(a:, 1, '')
		let postfix = get(a:, 2, '')
		return prefix.a:str.postfix
endfunction

au WinLeave * call setwinvar(winnr(), 'WinActive', 0)
au WinEnter,VimEnter * call setwinvar(winnr(), 'WinActive', 1)

set laststatus=2 " always
set statusline=
set statusline+=%#SLColorNormal#%3{SLStr('N')}
set statusline+=%#SLColorInsert#%3{SLStr('I')}
set statusline+=%#SLColorVisual#%3{SLStr('V')}
set statusline+=%#SLColorOther#%3{SLStr('?')}%*
set statusline+=%#Red#%m%*%h%w
set statusline+=\ %{GetStr(expand('%:t'),'[New]')}
set statusline+=\ %<%{GetStr(expand('%:h'),'','\|\ ')}
set statusline+=\ %=%#SLColorLineCol#\ %l:%c\ %*

"" color
set t_Co=256
set bg=dark

hi Red cterm=bold ctermfg=red ctermbg=none
hi SLColorNormal cterm=bold ctermfg=28 ctermbg=148
hi SLColorInsert cterm=bold ctermfg=18 ctermbg=75
hi SLColorVisual cterm=bold ctermfg=130 ctermbg=208
hi SLColorOther  cterm=bold ctermfg=15 ctermbg=0
hi SLColorLineCol ctermfg=8 ctermbg=7
hi StatusLine ctermfg=61 ctermbg=255
hi StatusLineNC ctermfg=239 ctermbg=247

hi Normal ctermbg=None
hi VertSplit ctermfg=black ctermbg=white
hi SpecialKey ctermfg=100
hi search ctermbg=117
hi TrailWS ctermbg=239
hi IndentGuidesOdd ctermbg=black ctermfg=100
hi IndentGuidesEven ctermbg=235 ctermfg=100
hi GitGutterAdd    ctermfg=2
hi GitGutterChange ctermfg=3
hi GitGutterDelete ctermfg=1

" Syntax
syntax on
au BufNewFile,BufRead Gemfile,Guardfile setlocal filetype=ruby
au FileType yaml setlocal et


""" Input
set mouse=n
set noet sw=2 ts=2 sts=2
set eol
set fileencodings=utf-8,cp949

function! TrimTrailingSpace()
	%s/\s\+$//e
endfunction
au BufWritePre    * :call TrimTrailingSpace()

set nosplitbelow
set splitright
set hlsearch
set incsearch


" include local rc
if filereadable(".vimrc.local")
	source .vimrc.local
endif


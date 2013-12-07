set nocompatible
source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin
"source $VIMRUNTIME/plugin/cscope_maps.vim
source $VIMRUNTIME/plugin/ack.vim
set diffexpr=MyDiff()
function! MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  let eq = ''
  if $VIMRUNTIME =~ ' '
    if &sh =~ '\<cmd'
      let cmd = '""' . $VIMRUNTIME . '\diff"'
      let eq = '"'
    else
      let cmd = substitute($VIMRUNTIME, ' ', '" ', '') . '\diff"'
    endif
  else
    let cmd = $VIMRUNTIME . '\diff'
  endif
  silent execute '!' . cmd . ' ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . eq
endfunction
"pathogen plud start
"call pathogen#infect()
"syntax on
"filetype plugin indent on
"pathogen plud end
"let g:xptemplate_bundle='perl'
set ic
set nu
"colorscheme slate
colo molokai
set incsearch
set hlsearch
set nobin
set tabstop=4
set shiftwidth=4
set shiftround
"set smartindent
"set guifont=Monaco:h9
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936,gb18030,big5,euc-jp,euc-kr,latin1
set ambiwidth=double
source $VIMRUNTIME/delmenu.vim  
source $VIMRUNTIME/menu.vim  
"set helplang=cn langmenu=zh_cn.utf-8
language messages zh_CN.UTF-8

set foldmethod=indent
set foldcolumn=4
set foldlevel=2
set foldopen=all
set foldclose=all
set nobackup

if has('win32')
set guifont=Courier_new:h10
elseif has('unix')
endif
"----------------map--------------------------
if has('win32')
map \v :e $VIM\_vimrc<cr><cr>
elseif has('unix')
map \v :e ~/.vimrc<cr><cr>
endif
map \t :Tagbar<cr><cr>
map \fo :NERDTree<cr><cr>
map \fc :NERDTreeClose<cr><cr>
map <f2> :call Do_my_hex()<cr><cr>
"map <f3> :call Do_my_note()<cr>
map <f3> :cp<cr><cr>
map <f4> :cn<cr><cr>
map \g :call Do_my_scrip()<cr><cr>
map <f6> :call Do_my_view()<cr><cr>
map \cd  :call Do_my_cd_current()<cr>
map \gctags  :!ctags -R<cr><cr>
map \cctags  :!del tags<cr><cr>
map \y "+y
map \p "+p
map \gcs :call Do_my_gen_cscope_file()<cr><cr>
map \ucs :call Do_my_update_cscope()<cr><cr>
"=============map functions==========================
fu! Do_my_cd_current()
	call My_update_file_name()
	exe ":cd ".s:path_dir
endf

"generate cscope file
fun! Do_my_gen_cscope_file()
	call My_update_file_name()
	exe ":cs kill 0"
	if has('win32')
	exe '!perl '."\"".$VIM."\"".'\cscope\cscope_files.pl '.s:path_all.' '."\"".$VIM."\""
		exe "!cs_gen.bat"
	elseif has('unix')
		exe '!perl ~/.vim/cscope/cscope_files.pl '.s:path_all
		"exe '!cscope -P s:path_dir'
		"exe '!cscope -Rbqk '.s:path_dir.'/*'
		exe '!rm cscope.in.out'
		exe '!del cscope.out'
		exe '!del cscope.po.out'
		exe '!del ncscope.in.out'
		exe '!del ncscope.out'
		exe '!del ncscope.po.out'
		exe '!cscope -Rbqk'
	endif
	exe ":cs a cscope.out"
endfun

fun! Do_my_update_cscope()
	exe ":cs kill 0"
	if has('win32')
		exe "!cs_gen.bat"
	elseif has('unix')
		exe '!cscope -Rbqk '.s:path_dir.'/*'
	endif
	exe ":cs a cscope.out"
endfun

"hex
let s:my_flag_hex=0
function! Do_my_hex()
if !s:my_flag_hex
	exe ":%!xxd"
	let s:my_flag_hex=1
elseif s:my_flag_hex
	exe ":%!xxd -r"
	let s:my_flag_hex=0
endif
endfunction
"---------------------------------------
function! Do_my_note()
	call My_update_file_name()
	if s:path_e==?"bat"
		call Do_my_note_bat()
	elseif s:path_e==?"pl"
		call Do_my_note_pl()
	elseif s:path_e==?"mak"
		call Do_my_note_mak()
	elseif s:path_e==?"vim" || s:path_file==?"_vimrc"
		call Do_my_note_vim()
	elseif s:path_e==?"c" || s:path_e==?"cpp"
		call Do_my_note_c()
	endif
endfunction

function! Do_my_note_bat()
	let line=getline(".")
	if line=~'^rem\s\+'
		exe "normal 0dw"
	elseif line=~'^\s\+rem\s\+'
		exe "normal 0frdw\<esc>"
	else
		exe "normal 0irem \<esc>"
	endif
endfunction

function! Do_my_note_pl()
	let line=getline(".")
	if line=~'^#'
		exe "normal 0x\<esc>"
	elseif line=~'^\s\+#'
		exe "normal 0f#x\<esc>"
	elseif line==''
		exe "normal 0i__END__\<esc>"
	elseif line=~'^\s*__END__\s*$'
		exe "normal ddO\<esc>"
	else
		exe "normal 0i#\<esc>"
	endif
endfunction

function! Do_my_note_mak()
	let line=getline(".")
	if line=~'^#'
		exe "normal 0x\<esc>"
	elseif line=~'^\s\+#'
		exe "normal 0f#x\<esc>"
	else
		exe "normal 0i#\<esc>"
	endif
endfunction

function! Do_my_note_vim()
	let line=getline(".")
	if line=~'^"'
		exe "normal 0x"
	elseif line=~'^\s\+\"'
		exe "normal 0f\"x\<esc>"
	else
		exe "normal 0i\"\<esc>"
	endif
endfunction

function! Do_my_note_c()
	let line=getline(".")
	if line=~'^//'
		exe "normal 0xx"
	elseif line=~'^\s\+//'
		exe "normal 0f/xx\<esc>"
	else
		exe "normal 0i//\<esc>"
	endif
endfunction
"---------------------------------------
function! Do_my_scrip()
	call My_update_file_name()
if s:path_e==?"pl"
	exe "!perl ".s:path_file
elseif s:path_e==?"bat"
	exe "!".s:path_file
endif
	echo "path is: ".s:path_all
endfunction

"---------------------------------------

function! Do_my_view()
	call My_update_file_name()
if has('win32')
	exe "!explorer ".s:path_dir
elseif has('unix')
	echo s:path_dir
	let @+=s:path_dir
endif
endfunction

"---------------------------------------
"sub functions
function! My_update_file_name()
let s:path_all=expand("%:p")
let s:path_e=expand("%:e")
let s:path_file=expand("%:t")
let s:path_dir=expand("%:p:h")
endfunction



" plugin =====================================================
"begin vundle
 set nocompatible               " be iMproved
     filetype off                   " required!

if has('win32')
	set rtp+=$VIM/bundle/vundle/
	call vundle#rc('$VIM/vundle_plugin')
elseif has('unix')
	set rtp+=~/.vim/bundle/vundle/
	call vundle#rc('~/.vim/vundle_plugin/')
endif
     "call vundle#rc()

     " let Vundle manage Vundle
	Bundle 'gmarik/vundle'
     " My Bundles here:
     "
     " original repos on github
     "Bundle 'tpope/vim-fugitive'
     "Bundle 'taglist.vim'
	Bundle 'L9'
	Bundle 'majutsushi/tagbar'
	Bundle 'FuzzyFinder'
	Bundle 'scrooloose/nerdtree'
	Bundle 'altercation/vim-colors-solarized'
	Bundle 'tomasr/molokai'
	Bundle 'zaiste/Atom'
	Bundle 'navajo-night'
	Bundle 'baskerville/bubblegum'
	Bundle 'bling/vim-airline'
	"depended by vimshell.vim 
	Bundle 'Shougo/vimproc'      
	Bundle 'Shougo/vimshell.vim'

	"start ctrlp
	"Bundle 'kien/ctrlp.vim'
	"let g:ctrlp_by_filename = 1
	"let g:ctrlp_custom_ignore = {
				"\ 'dir':'\.git$\|\.svn$\|build',
				"\ 'file':'\.db$\|\.rar$\|\.zip$\|\~$\|\.obj\|\.mp3\|\.mid\|\.png\|\.bmp\|\.jpg\|\.gif\|\.exe\|\.dll\|\.lib\|\.db\|\.bak',
				"\ 'link':'SOME_BAD_SYMBOLIC_LINKS',
				"\ }
	"let g:ctrlp_max_files = 0
	"let g:ctrlp_max_depth = 40
	"let g:ctrlp_use_caching = 1
	"let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'
	"let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:10,results:200'
	"let g:ctrlp_clear_cache_on_exit = 0
	"let g:ctrlp_working_path_mode = 'w'
	"let g:ctrlp_lazy_update = 500
	"let g:ctrlp_show_hidden = 1
	"end ctrlp

	"snipmate
	Bundle "MarcWeber/vim-addon-mw-utils"
	Bundle "tomtom/tlib_vim"
	Bundle "garbas/vim-snipmate"
	Bundle "honza/vim-snippets"
"	Bundle 'Shougo/neocomplete.vim'
"	mark
	Bundle "vim-scripts/Mark"
"	nerd commenter
	Bundle "vim-scripts/The-NERD-Commenter"
"cscope map
	Bundle "chazy/cscope_maps"
	"CCTree,map tree,need cscope
	Bundle "vim-scripts/CCTree"
	"lookupfile
	Bundle "vim-scripts/genutils"
	Bundle "vim-scripts/lookupfile"
" lookupfile.vim 插件设置
let g:LookupFile_MinPatLength = 2               "最少输�?个字符才开始查�?
let g:LookupFile_PreserveLastPattern = 0        "不保存上次查找的字符�?
let g:LookupFile_PreservePatternHistory = 0     "保存查找历史
let g:LookupFile_AlwaysAcceptFirst = 1          "回车打开第一个匹配项�?
let g:LookupFile_AllowNewFiles = 0              "不允许创建不存在的文�?
let g:LookupFile_SortMethod = ""                "关闭对搜索结果的字母排序
call My_update_file_name()
if filereadable(s:path_dir.'\filenametags')                "设置tag文件的名�?
"let g:LookupFile_TagExpr =s:path_dir.'\filenametags'
"let g:LookupFile_TagExpr ='"'.s:path_dir.'\filenametags'.'"'
let g:LookupFile_TagExpr = string('./filenametags')
endif

	"minbufexp
	Bundle "fholgado/minibufexpl.vim"
	let g:miniBufExplMapCTabSwitchBufs=1
	let g:miniBufExplMapWindowsNavVim=1
	let g:miniBufExplMapWindowNavArrows=1
	hi MBENormal               guifg=#808080 guibg=fg
	hi MBEChanged              guifg=#CD5907 guibg=fg
	hi MBEVisibleNormal        guifg=#5DC2D6 guibg=fg
	hi MBEVisibleChanged       guifg=#F1266F guibg=fg
	hi MBEVisibleActiveNormal  guifg=#A6DB29 guibg=fg
	hi MBEVisibleActiveChanged guifg=#F1266F guibg=fg
     " ...
     filetype plugin indent on     " required!
     " or 
     " filetype plugin on          " to not use the indentation settings set by plugins
"end vundle
"begin tagbar
let g:tagbar_show_linenumbers = 1
"let g:tagbar_autoshowtag = 1
"autocmd VimEnter * :Tagbar
"end tagbar
"begin nerdtree
let NERDTreeShowBookmarks = 1
let NERDTreeShowLineNumbers = 1
let NERDTreeChDirMode = 2
let NERDTreeShowHidden = 1
let NERDTreeHijackNetrw = 0
let NERDTreeShowFiles = 1
"autocmd VimEnter * :NERDTree
"end nerdtree
"start cscope
	if has("cscope")
"		set csprg=/usr/local/bin/cscope
if has('win32')
		set csprg=$VIM/cscope/cscope.exe
elseif has('unix')
		set csprg=/usr/bin/cscope
endif
		set csto=0
		set cst
		set cscopequickfix=s-,c-,d-,i-,t-,e-
"		set cscopequickfix=s+,c+,d+,i+,t+,e+
"		set nocsverb
		" add any database in current directory
"		if filereadable("cscope.out")
"		    cs add cscope.out
"		 else add database pointed to by environment
"		elseif $CSCOPE_DB != ""
"		    cs add $CSCOPE_DB
"		endif
"		set csverb
	endif
"end cscope


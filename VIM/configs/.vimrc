"#Set things up for vundle
" Run the following git clone command
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" Run the following command to install plugins
" :PluginInstall

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

Plugin 'vim-scripts/taglist.vim'

" requred in bash for ctrl+s: stty stop undef # to unmap ctrl-s
" open ipython qtconsole
" run :IPython
" Plugin 'ivanov/vim-ipython'

" toggles comments with gc
Plugin 'tpope/vim-commentary.git'


" switches between header and source
" Plugin 'vim-scripts/a.vim.git'

" syntax
" Plugin 'vim-scripts/scons.vim.git'
" Plugin 'vim-scripts/SWIG-syntax.git'

" opening companion files
" might be better than a.vim?
" Plugin 'derekwyatt/vim-fswitch'
" settings are in .vim/after/plugin/fswitch.vim

" awesome motion commands
" Plugin 'Lokaltog/vim-easymotion'

" autocomplete
"    cd ~/.vim/bundle/YouCompleteMe
"    ./install.sh --clang-completer
"    http://susu.github.io/posts/clang-completion-in-vim-with-youcompleteme/
"    sudo apt-get install clang-format-3.6
"    sudo add-apt-repository ppa:pkg-vim/vim-daily
"    sudo apt-get update && sudo apt-get upgrade
" Plugin 'Valloric/YouCompleteMe'

"Bundle 'majutsushi/tagbar'
" shows multiple files nicely
" <F1> for help doesn't work
" doesn't show vim leader (taglist does)

" required for vim-clang-format
Bundle 'kana/vim-operator-user.git'

" formatting for c, c++ files
Bundle 'rhysd/vim-clang-format'

" python lint, lots of other stuff
Bundle 'klen/python-mode'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on

" TODO: move this to c files stuff?
""" clang format options ---------------------------------
let g:clang_format#command = "clang-format-3.6"
let g:clang_format#style_options = {
            \ "AccessModifierOffset" : -4,
            \ "AllowShortIfStatementsOnASingleLine" : "true",
            \ "AlwaysBreakTemplateDeclarations" : "true",
            \ "ColumnLimit" : 110,
            \ "Standard" : "C++11"}

" map to <Leader>cf in C++ code
autocmd FileType c,cpp,objc nnoremap <buffer><Leader>f :<C-u>ClangFormat<CR>
autocmd FileType c,cpp,objc vnoremap <buffer><Leader>f :ClangFormat<CR>
" if you install vim-operator-user
autocmd FileType c,cpp,objc map <buffer><Leader>x <Plug>(operator-clang-format)
" Toggle auto formatting:
nmap <Leader>C :ClangFormatAutoToggle<CR>

set backspace=2 "make it work like other aps(?)

set shiftwidth=4
set tabstop=4
set softtabstop=4
set smarttab
set expandtab

" autocompletion of file browsing
set wildmenu
set wildmode=longest:list

set title  " show name of file in tab

" show white space?
set list
set listchars=tab:>.,trail:.,extends:#,nbsp:.

" avoid hitting Esc so much
inoremap jk <C-[>
" C-[ is better than Esc, not clear why

imap <silent> <Down> <C-o>gj
imap <silent> <Up> <C-o>gk
nmap <silent> <Down> gj
nmap <silent> <Up> gk

set number
nnoremap <F2> :set nonumber!<CR>
set pastetoggle=<F2>

" tab movement
nnoremap <C-I> :tabprev<CR>
nnoremap <C-O> :tabnext<CR>
" inoremap <C-I> <Esc>:tabprev<CR>
" inoremap <C-O> <Esc>:tabnext<CR>

" split movement
nmap <C-K> <C-w><Up>
nmap <C-J> <C-w><Down>
nmap <C-L> <C-w><Right>
nmap <C-H> <C-w><Left>
set splitbelow
set splitright

" window resizing
nnoremap <silent> + :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> - :exe "resize " . (winheight(0) * 2/3)<CR>

""" MOVE THIS TO PYTHON FILE -------------------
""" python-mode mappings ----------------------------
let g:pymode_doc_key = 'K'

let g:pymode_rope_completion = 0
let g:pymode_rope_lookup_project = 0

" syntax highlighting
let g:pymode_syntax = 1
let g:pymode_syntax_all = 1
let g:pymode_syntax_indent_errors = g:pymode_syntax_all
let g:pymode_syntax_space_errors = g:pymode_syntax_all

" let g:pymode_folding = 0  " comletely disable folding
set foldlevelstart=2

"Lint
let g:pymode_lint = 1
" let g:pymode_lint_checker = "pylint, pep8"  " mccabe, pyflakes, others?
let g:pymode_lint_checker = "flake8"  " mccabe, pyflakes, others?
let g:pymode_lint_write = 1  " auto check on save

" let g:pymode_lint_config = '$HOME/.vim/pylint.rc'
let g:pymode_lint_options_pep8 = {'max_line_length': 110}  " if no config file
" then draw the line in the right place
let g:pymode_options_max_line_length = g:pymode_lint_options_pep8['max_line_length']
highlight ColorColumn term=reverse cterm=reverse gui=reverse  " gray


""" easymotion mappings -----------------------------
" let g:EasyMotion_do_mapping = 1 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding
nmap <Space> <Plug>(easymotion-s)
" s2 also an option
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
" somehow these get over written
nmap <Leader>j <Plug>(easymotion-j)
nmap <Leader>k <Plug>(easymotion-k)


" easy way to make vertical splits bigger
nnoremap <C-n> <C-w>>
" for some reason <C-n> doesn't work

" for interaction with ipython, needs running ipython qtconsole and :IPython
nnoremap <silent> <F4> :silent w <CR>:silent python run_this_file()<CR>
inoremap <F4> <ESC>:w <CR>:python run_this_file()<CR>

" search options
set incsearch
set hlsearch
" get rid of highlighting
nnoremap <silent><CR> :nohlsearch<CR><CR>

" not sure if these are needed
" highlight NonText guibg=#060606
" highlight Folded guibg=#0A0A0A guifg=#9090D0

" complete options (what does this set?)
set completeopt=menu,menuone


" leader key
let mapleader=","

" Spellcheck trigger
nmap <silent> <leader>sp :set spell!<CR>

" Key mapping for simple .vimrc editing
nmap <silent> <leader>ev :tabe $MYVIMRC<CR>

" Source .vimrc file
map <leader>sv :source $MYVIMRC<CR>

" Open tag bar
map <silent> <leader>l :TagbarToggle<CR>

" Open taglist, does multiple buffers
map <silent> <leader>; :TlistToggle<CR>


" Run ctags - read by YCM
map <leader>tg :! ctags -R .<CR>

map <leader>fp :PymodeLintAuto<CR>

" file types to recognize
au BufNewFile,BufRead SCons* set filetype=scons
au BufNewFile,BufRead CMake* set filetype=cmake
au BufNewFile,BufRead *.i set filetype=swig
au BufNewFile,BufRead *.swig set filetype=swig
au bufnewfile,bufread *.ino set filetype=c  " arduino files

autocmd BufRead,BufNewFile *.launch setfiletype roslaunch

autocmd FileType scons set commentstring=#\ %s
autocmd FileType cmake set commentstring=#\ %s
autocmd FileType cpp set commentstring=//\ %s
autocmd FileType swig set commentstring=//\ %s
autocmd FileType c set commentstring=//\ %s

"  a.vim settings
"  prevent opening file if not found
let g:alternateNoDefaultAlternate=1

" allow sudo write
cmap w!! w !sudo tee > /dev/null %

" close menu (doesn't work on everything)
autocmd CursorMovedI *  if pumvisible() == 0|silent! pclose|endif
autocmd InsertLeave * if pumvisible() == 0|silent! pclose|endif

" Execution
nnoremap  fd :exec 'w' <cr> :exec '! python %' <cr>
nnoremap <buffer> ! :exec '! python %' <cr>
nnoremap <buffer> @ :exec 'w' <cr>
nnoremap <buffer> > <C-w>>
nnoremap <buffer> < <C-w><
command R !./%

map <leader>a oassert(False)<ESC>
map <leader>p oprint<ESC>
map <leader>w oraw_input("break")<ESC>

command! -nargs=1 SS let @/ = '\V'.escape(<q-args>, '\')

syntax enable
colorscheme monokai

" Added to make it so can cut and paste from different terminals must have
" vim-gnome installed
set clipboard=unnamedplus

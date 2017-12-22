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

" toggles comments with gc
Plugin 'tpope/vim-commentary.git'

" All of your Plugins must be added before the following line
call vundle#end()
filetype plugin indent on

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
" C-[ is better than Esc, not clear why
inoremap jk <C-[>

" ability to move down one displayed line of wrapped code vs. one actual line of code
imap <silent> <Down> <C-o>gj
imap <silent> <Up> <C-o>gk
nmap <silent> <Down> gj
nmap <silent> <Up> gk

" make sure that the text doesn't wrap as I'm typing long lines of code that I
:set tw=0

" show line numbers when vim starts
set number
" toggle line numbers on and off with F2
nnoremap <F2> :set nonumber!<CR>

" Paste toggle, to paste text from other sources and not have indenting screwed up (from insert mode)
set pastetoggle=<F2>

" tab movement between tabs ctrl-i goes left and ctrl-o goes right
nnoremap <C-I> :tabprev<CR>
nnoremap <C-O> :tabnext<CR>

" split movement move between splits with ctrl+ navigation keys (j,k,l,h)
nmap <C-K> <C-w><Up>
nmap <C-J> <C-w><Down>
nmap <C-L> <C-w><Right>
nmap <C-H> <C-w><Left>
" make it so that :sp automatically puts the split below not above
set splitbelow
" make it so that the :vsp command automatically puts the split to the right not the left 
set splitright

" make windows bigger or smaller with + and -
nnoremap <silent> + :exe "resize " . (winheight(0) * 3/2)<CR>
nnoremap <silent> - :exe "resize " . (winheight(0) * 2/3)<CR>

" set the vertical grey line that shows how much code will fit in a word doc w/ 1" margins
set colorcolumn=104

" easy way to make vertical splits bigger
nnoremap <C-n> <C-w>>
"---------------------Made it to here looking through .vimrc-------------------------------------------
" Jump to anywhere you want with minimal keystrokes, with just one key binding
nmap <Space> <Plug>(easymotion-s)
" s2 also an option

" JK motions: Line motions
" somehow these get over written
nmap <Leader>j <Plug>(easymotion-j)
nmap <Leader>k <Plug>(easymotion-k)

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
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

map <leader>a oassert(False)<ESC>
map <leader>p oprint<ESC>
map <leader>w oraw_input("break")<ESC>

command! -nargs=1 SS let @/ = '\V'.escape(<q-args>, '\')

syntax enable
colorscheme monokai

" Added to make it so can cut and paste from different terminals must have
" vim-gnome installed
set clipboard=unnamedplus

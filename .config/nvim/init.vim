" " Set mapleader to space by default, early so all mappings by plugins are set
" if !exists("mapleader")
"   let mapleader = "\<Space>"
" endif

" Disable strange Vi defaults.
set nocompatible

" ================================
"           Plugins
" ================================

" download vim-plug if missing
if empty(glob("~/.local/share/nvim/site/autoload/plug.vim"))
  silent! execute '!curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * silent! PlugInstall
endif

" manage plugins
silent! if plug#begin('~/.local/share/nvim/plugged')
  " --- SECURITY
 
  " Protect leaks when editting pass(1) files
  let g:plug_shallow = 0 " work-around until shallow option can be set per plugin
  " secure usage of `$pass <command>` that uses the editor
  Plug 'https://dev.sanctum.geek.nz/code/vim-redact-pass.git'

  " --- NAVIGATION
 
  " vim-tmux navigation
  Plug 'christoomey/vim-tmux-navigator'

  " terminal-based file manager
  Plug 'mcchrish/nnn.vim'

  " --- UI
 
  " vscode-like color scheme
  Plug 'tomasiser/vim-code-dark'

  " preview colors in source code
  Plug 'ap/vim-css-color'

  " display vertical bars on indentation levels
  Plug 'Yggdroot/indentLine'

  " --- UTILS
 
  " unix utils (mostly fs)
  Plug 'tpope/vim-eunuch'

  " git utils
  Plug 'tpope/vim-fugitive'

  " mappings to easily delete, change and add such surroundings (parens, brackers, etc.) in pairs
  Plug 'tpope/vim-surround'

  " comment stuff out
  Plug 'tpope/vim-commentary'

  " insert or delete brackets, parens, quotes in pair
  Plug 'jiangmiao/auto-pairs'

  " fuzzy find operator
  Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
  Plug 'junegunn/fzf.vim'

  " preview markdown files in browser
  Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug'] }

  " renamer
  Plug 'dkprice/vim-easygrep'

  " --- LSP
 
  " language packs (basic syntax highlighting)
  Plug 'sheerun/vim-polyglot'

  " lsp
  Plug 'prabirshrestha/vim-lsp'
  Plug 'mattn/vim-lsp-settings'

  " autocomplete
  Plug 'prabirshrestha/asyncomplete.vim'
  Plug 'prabirshrestha/asyncomplete-lsp.vim'

  " snippets
  Plug 'hrsh7th/vim-vsnip'
  Plug 'hrsh7th/vim-vsnip-integ'

  " --- LANGUAGE-SPECIFIC
 
  " emmet expansion
  Plug 'mattn/emmet-vim'

  " golang helpers
  Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

  " protobuf
  Plug 'uarun/vim-protobuf'

  " --- APPS

  Plug 'soywod/himalaya', {'rtp': 'vim'}

  call plug#end()

  " -- VSCode theme
  silent! colorscheme codedark                            
  
  " -- javascript
  let g:javascript_plugin_jsdoc = 1
  
  " -- Autopairs
  let g:AutoPairsShortcutToggle = ''
  
  " -- Vim Tmux Navigation
  let g:tmux_navigator_disable_when_zoomed = 1

  " -- nnn
  let g:nnn#layout = { 'window': { 'width': 0.9, 'height': 0.6, 'highlight': 'Debug' } }
  let g:nnn#action = {
      \ '<c-t>': 'tab split',
      \ '<c-x>': 'split',
      \ '<c-v>': 'vsplit' }

  " -- Vim Markdown
  let g:vim_markdown_conceal = 0
  let g:vim_markdown_conceal_code_blocks = 0
  
  " -- Markdown Preview
  let g:mkdp_refresh_slow = 1

  " -- FZF
  let g:fzf_buffers_jump = 1

  " -- lsp
  let g:lsp_diagnostics_enabled = 0         " disable diagnostics support

  " -- Himalaya
  let g:himalaya_mailbox_picker = 'fzf'
endif


" ================================
"          FS
" ================================

" enable filetype detection
if has('autocmd')
  filetype plugin indent on
endif

" disable auto changedir
set noautochdir

" enable backup files
set backup
set writebackup
set backupdir=/tmp//

" enable swap files
set directory=/tmp//

" enable undo files
if has('persistent_undo')
  set undofile
  set undodir=/tmp//
endif

" native file explorer config
let g:netrw_banner = 0
" tree view
let g:netrw_liststyle = 3           


" ================================
"     Spacing and Indentation
" ================================

" set up indents to use 2 spaces
set shiftwidth=2                    
" number of visual spaces per TAB
set tabstop=2                       
" number of spaces in tab when editing
set softtabstop=2                   
" tabs are spaces
set expandtab                       
" auto indent on new lines
set autoindent                      


" ================================
"          UI
" ================================

" enable syntax higlighting
if has('syntax') && !exists('g:syntax_on')
  syntax enable
endif
" hide line numbers
set nonumber                          
" show command in bottom bar
set showcmd                         
" highlight current line
set cursorline                      
" visual autocomplete for command menu
set wildmenu                        
" redraw only when we need to.
set lazyredraw                      
" highlight matching [{()}]
set showmatch                       
" no wrapping by default
set nowrap                          
" more natural splitting
set splitright                      
set splitbelow                      


" ================================
"          Clipboard
" ================================

if system('uname -s') == "Darwin\n"
  "OSX
  set clipboard=unnamed 
else
  "Linux
  set clipboard=unnamedplus 
endif


" ================================
"          Diff
" ================================

" make Vim use vsplits for diff mode
set diffopt+=vertical               


" ================================
"          Folding
" ================================

" enable folding
set foldenable                      
" open most folds by default
set foldlevelstart=0               
" 10 nested fold max
set foldnestmax=10                  
" fold methods
" set foldmethod=indent
set foldmethod=syntax
" set foldmethod=expr
"   \ foldexpr=lsp#ui#vim#folding#foldexpr()
"   \ foldtext=lsp#ui#vim#folding#foldtext()
" space open/closes folds
nnoremap <space> za
" remember folds
" augroup remember_folds
"   autocmd!
"   autocmd BufWinLeave * silent! mkview
"   autocmd BufWinEnter * silent! loadview
" augroup END


" ================================
"          Searching
" ================================

" -- searching
" search as characters are entered
set incsearch                       
" highlight matches
set hlsearch                        
hi Search cterm=NONE ctermfg=White ctermbg=DarkYellow
" turn off search highlight using \<space>
nnoremap <leader><space> :nohlsearch<CR>

" -- ripgrep
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(
  \   'rg --column --line-number --hidden --ignore-case --no-heading --color=always '.shellescape(<q-args>), 1,
  \   <bang>0 ? fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'up:60%')
  \           : fzf#vim#with_preview({'options': '--delimiter : --nth 4..'}, 'right:50%:hidden', '?'),
  \   <bang>0)

" -- override grepprg
set grepprg=rg\ --vimgrep


" ================================
"         Start statusline
" ================================

" make Vim display the statusline at all times
" but the tabline only when necessary
set laststatus=2
set showtabline=1

function! GitBranch()
  return system("git rev-parse --abbrev-ref HEAD 2>/dev/null | tr -d '\n'")
endfunction

function! StatuslineGit()
  let l:branchname = GitBranch()
  return strlen(l:branchname) > 0?'  '.l:branchname.' ':''
endfunction

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{StatuslineGit()}
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=\ %3*%m
set statusline+=%=
set statusline+=%#CursorColumn#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
set statusline+=\ %p%%
set statusline+=\ %l:%c
set statusline+=\ (%L)
set statusline+=\ 


" ================================
"         Autocommands
" ================================

augroup Linting
	autocmd!
  autocmd FileType vue setlocal makeprg=yarn\ lint
  autocmd FileType javascript setlocal makeprg=yarn\ lint
augroup END

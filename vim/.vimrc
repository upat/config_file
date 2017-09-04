"vim内部で使用する文字コード
set encoding=utf-8

"文字コードの自動認識 by http://www.kawaz.jp/pukiwiki/?vim
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  "iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
    "iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  "fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  "定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
"日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
"改行コードの自動認識
set fileformats=unix,dos,mac
"□とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif



"--------------------------------------------------------------------------------
"NeoBundleプラグインの設定
"
"bundleで管理するディレクトリを指定 & Required
set runtimepath+=~/.vim/bundle/neobundle.vim/ 
call neobundle#begin(expand('~/.vim/bundle/'))
"neobundle自体をneobundleで管理
NeoBundleFetch 'Shougo/neobundle.vim'
"管理するプラグイン
NeoBundle 'itchyny/lightline.vim'
NeoBundle 'w0ng/vim-hybrid'
NeoBundle 'nanotech/jellybeans.vim'
NeoBundle 'Townk/vim-autoclose'
call neobundle#end()
"Required
filetype plugin indent on
"プラグインの更新チェック
NeoBundleCheck



"--------------------------------------------------------------------------------
"lightlineプラグインの設定
"
let g:lightline = {'colorscheme': 'jellybeans'}



"--------------------------------------------------------------------------------
"基本的な設定
"
"この文字コードでファイルが保存される(デフォルト値)
set fileencoding=utf-8
"バックスペースキーで削除できるものを指定
set backspace=indent,eol,start
"バックアップを取らない
set nobackup
"undofileを作成しない
set noundofile
"swapfileを作成しない
set noswapfile
"範囲選択と同時にクリップボードへコピー
set clipboard=unnamed,autoselect
"viモードの無効化
set nocompatible
"マウス使用の設定
set mouse=a
set ttymouse=xterm2
"色の設定
set term=xterm
set t_Co=256
"挿入モード時にIMEをオフにする
set iminsert=0
set imsearch=-1
"開いているファイルのディレクトリに自動で移動する
set autochdir



"--------------------------------------------------------------------------------
"表示関係の設定
"
"行番号を表示
set number
"ルーラーを表示
set ruler
"シンタックスハイライトを有効にする
syntax on
"タイトルをウィンドウ枠に表示しない
set notitle
"カラースキームの設定
colorscheme jellybeans
hi Comment gui=NONE
"対応する括弧の表示時間を 2 に設定
set matchtime=2
"コマンドラインの高さ(GUI使用時)
set cmdheight=2
"コマンドラインの下から2行目にステータスバーを表示
set laststatus=2
"行番号のハイライト設定
set cursorline
hi CursorLineNr term=NONE cterm=NONE ctermfg=173 ctermbg=NONE



"--------------------------------------------------------------------------------
"インデント
"
"タブが対応する空白の数
set tabstop=4
"キーボードからタブ挿入時の対応する空白の数(0でtabstopの値)
set softtabstop=0
"インデントの各段階に使われる空白の数
set shiftwidth=4
"タブを挿入するとき、代わりに空白を使わない
set noexpandtab
"オートインデントを有効にする
set autoindent
"breakindentを有効にする
set breakindent
"wrapを有効にする
set wrap



"--------------------------------------------------------------------------------
"検索関連
"
"検索文字列が小文字の場合は大文字小文字区別なく検索する
set ignorecase
"検索文字列に大文字が含まれている場合は区別して検索する
set smartcase
"検索時に最後まで行ったら最初に戻る
set wrapscan
"検索文字入力時に順次対象文字列にヒットさせない
set noincsearch
"検索結果文字列のハイライトを有効にする
set hlsearch



"--------------------------------------------------------------------------------
"各種autocmd
"
"PythonのTab幅が強制的に8文字に設定されるのを回避
autocmd FileType python set tabstop=4
"新規ファイル作成時、強制的に改行コードがunixになるのを回避 in MSYS2
"(ただしファイル展開せずに起動した場合は無効)
autocmd BufnewFile * set fileformat=dos 

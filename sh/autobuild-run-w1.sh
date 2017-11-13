#!/bin/sh
gcc='gcc -W -Wall'
exe='_test.exe'
exelog='_test.log.txt'

# 第6週レポート用 for MSYS2
# 処理を行うファイル名の指定(無指定の場合は*.c)
echo -n "select file name: "
read inputf
if [ -z "$inputf" ]; then
  inputf="*.c"
fi
echo input str is 『 $inputf 』

# Rドライブのディレクトリ下にある.cファイル(フルパスで出力)の検索
for file in `\find /R/ -type f -name $inputf`; do
	# 検索したパスから拡張子を除去したファイル名を生成
	fname=$(basename $file | sed 's/\.[^\.]*$//')
	# 検索したパスからファイル名を含まないパスを生成
	path=$(dirname $file)
	# コンパイル後の実行ファイル名
	output=$path/$exe
	# 実行結果の標準出力に使うテキストファイル名
	txtfile=$path/$exelog

  # ログファイルが存在しない場合のみ実行
  # （ソースファイル数と同じ回数コンパイルを繰り返すため）
  if [ ! -e $txtfile ]; then
	  echo -e "\e[36m$gcc $path/$inputf -o $output\e[m"
    echo -en "\e[31m"
	  $gcc $path/$inputf -o $output
    echo -en "\e[m"
    # 実行ファイルの生成に失敗した場合空のtxtを出力
    if [ -e $output ]; then
	    $output > $txtfile
    else
      echo -e "\e[35mexe file create failed.\e[m"
      touch $txtfile
    fi
  else
    echo -e "\e[32malready compiled.\e[m"
  fi
done
echo -en "\e[m" #なんらかの理由でループが途切れた時用


#!/bin/sh
gcc='gcc -W -Wall'

# 第1週レポート用 for MSYS2
# Rドライブのディレクトリ下にある.cファイル(フルパスで出力)の検索
for file in `\find /R/ -type f -name *.c`; do
	# 検索したパスから拡張子を除去したファイル名を生成
	fname=$(basename $file | sed 's/\.[^\.]*$//')
	# 検索したパスからファイル名を含まないパスを生成
	path=$(dirname $file)
	# コンパイル後の実行ファイル名
	output=$path/$fname.exe
	# 実行結果の標準出力に使うテキストファイル名
	txtfile=$path/$fname.log.txt

	echo $file
	$gcc $path/*.c -o $output
	$output > $txtfile
done

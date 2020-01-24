#!/usr/bin/env bash

echo "baixando educapes"

rm -rf "wget-log"

cd downloads

rm -rf *

files=( "data1.bin" "data2.bin" "data3.bin" "data4.bin" "data5.bin" "data6.bin" "data7.bin" )

for FILE in "${files[@]}"; do
	wget --limit-rate=100K --progress=dot:giga -c -t 0 -o ../wget-log http://localhost/"$FILE"
done




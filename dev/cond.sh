#!/usr/bin/env bash

s=2
d=2

if [[ $s == $d ]]; then
        echo 's and d are the same'
fi

f=2
g=3

if [[ $f == $g ]]; then
        echo 'f and g are the same'
else
        echo 'f and g are not the same'
fi

while [[ -f file.txt ]]; do
        echo 'file.txt exists and is a file'
        sleep 1
done

echo 'file is gone'

if echo hi; then
        echo 'echo worked'
fi
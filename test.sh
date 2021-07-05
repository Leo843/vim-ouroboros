#!/bin/bash

# iterate over all vim files in ./test/ and run them with vim
for file in ./test/*.vim
do
  vim --clean -S $file
done


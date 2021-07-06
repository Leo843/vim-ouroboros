#!/bin/bash

# clean results from previous run
echo "" > test.out

# iterate over all vim files in ./test/ and run them with vim
for file in ./test/test-*.vim
do
  vim --clean -S $file
done

# print failures
grep failure test.out

# print number of successes and failures
nb_success=$(grep success test.out | wc -l)
nb_failure=$(grep failure test.out | wc -l)
echo "successes $nb_success, failures $nb_failure"

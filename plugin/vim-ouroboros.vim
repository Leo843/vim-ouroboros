" Last Change: 2021 Jul 1
" Maintainer:	Leo Carpenter <leo.carpenter.pro@gmail.com>
" License: see doc/ouroboros.txt

if exists("g:loaded_ouroboros")
  finish
endif
let g:loaded_ouroboros=1

" Path to the file that contains all Ouroboros entries. An Ouroboros entry is a
" line containing words separated by at least one space/tab.
let g:ouroboros_db='$HOME/.vim/ouroboros.db'

" preconditions:
"   a:candidates is a string containings words separated by spaces/tabs and a:word
"   is a one of those words.
" postconditions:
"   The next word after a:word in a:candidates is returned. If a:word id the
"   last word in a:candidates, then the first word of the string is returned.
function Ouroboros_new_word(word, candidates)
  " get a list of words from a string
  let l:candidates = split(a:candidates)
  " find the index of the current word
  let l:index = index(l:candidates, a:word)
  " throw if a:word does not exist in the list
  if l:index == -1
    throw '' . a:word . ' not found in ' . a:candidates
  endif
  " return the index of the word
  let l:next_index = l:index + 1
  if l:next_index == len(l:candidates)
    return l:candidates[0]
  else
    " rollover if a:word is the last of the list
    return l:candidates[l:next_index]
  endif
endfunction

" preconditions:
"   a:word is a word (avoid special characters)
" postconditions:
"   A string is returned. If a:word exists in file g:ouroboros_db, then the
"   first line containing a:word is returned, otherwise, an empty string is
"   returned.
function! Ouroboros_candidates(word)
  return matchstr(readfile(expand(g:ouroboros_db)), a:word)
endfunction

" Ouroboros entry point
"
" Replace the word under cursor by the next word define in the first entry in
" the Ouroboros database file. If the word undex cursor is not define in the
" Ouroboros database file, then nothing happens.
function! Ouroboros()
  try
    let l:old_word = expand("<cword>")
    let l:candidates = Ouroboros_candidates(l:old_word)
    if strlen(l:candidates) > 0
      let l:new_word = Ouroboros_new_word(l:old_word,l:candidates)
      exe "normal ciw" . l:new_word
    else
      echo 'Ouroboros failure: no entry found for "' . l:old_word . '"'
    endif
  catch
    echo 'Ouroboros error: ' . v:exception
  endtry
endfunction

nnoremap <silent> <leader>o :call Ouroboros()<CR>

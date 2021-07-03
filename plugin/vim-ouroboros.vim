" Last Change: 2021 Jul 1
" Maintainer:	Leo Carpenter <leo.carpenter.pro@gmail.com>
" License: see doc/ouroboros.txt

if exists("g:loaded_ouroboros")
  finish
endif
let g:loaded_ouroboros=1

" Return the root directory of the plugin (symlinks are resolved).
function! s:Plugin_root_dir()
  return fnamemodify(resolve(expand('<sfile>:p')), ':h:h')
endfunction

" Return the path to the default database file
function! Ouroboros_default_database_file_path()
  return  '' . s:Plugin_root_dir() . '/db/ouroboros.db'
endfunction

" Reset g:ouroboros_db with the default database path
function! Ouroboros_set_default_database()
  let l:default_db=Ouroboros_default_database_file_path()
  let g:ouroboros_db=[l:default_db]
  if !filereadable(l:default_db)
    echoerr 'Ouroboros error: default db "'.l:default_db.'" cannot be read'
  endif
endfunction

" If the user did not provide any path, then set the default path for the
" database file.
if !exists("g:ouroboros_db")
  call Ouroboros_set_default_database()
endif

" preconditions:
"   a:candidates is a string containings words separated by spaces/tabs and a:word
"   is a one of those words.
" postconditions:
"   The next word after a:word in a:candidates is returned. If a:word id the
"   last word in a:candidates, then the first word of the string is returned.
function! Ouroboros_new_word(word, candidates)
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

" Return databases attached to the current buffer if any, otherwise return the
" global databases.
function! Ouroboros_databases()
  if exists("b:ouroboros_db")
    return b:ouroboros_db
  else
    return g:ouroboros_db
endfunction

" preconditions:
"   a:word is a word (avoid special characters)
" postconditions:
"   A string is returned. If a:word exists in file g:ouroboros_db, then the
"   first line containing a:word is returned, otherwise, an empty string is
"   returned.
function! Ouroboros_candidates(word)
  for db in Ouroboros_databases()
    let l:candidates=matchstr(readfile(expand(db)), a:word)
    if strlen(l:candidates) > 0
      return l:candidates
    endif
  endfor
  return ''
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

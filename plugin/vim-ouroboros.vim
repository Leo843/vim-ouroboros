" Maintainer:	Leo Carpenter <leo.carpenter.pro@gmail.com>
" License: see doc/ouroboros.txt

if exists("g:loaded_ouroboros")
  finish
endif
let g:loaded_ouroboros=1

" path to this script with symlinks resolved
let s:this_script_filepath=resolve(expand('<sfile>:p'))
" path to the root dir of the plugin
let s:this_plugin_root_dir=fnamemodify(s:this_script_filepath, ':h:h')
" path to the default database
let s:default_database_filepath='' . s:this_plugin_root_dir . '/db/ouroboros.db'

" Reset g:ouroboros_db with the default database path
function! Ouroboros_set_default_database()
  if !filereadable(s:default_database_filepath)
    echoerr 'Ouroboros: '.s:default_database_filepath.' cannot be read'
  endif
  let g:ouroboros_db=[s:default_database_filepath]
endfunction

" If the user did not provide any path, then set the default path for the
" database file.
if !exists("g:ouroboros_db")
  call Ouroboros_set_default_database()
endif

" preconditions:
"   a:candidates is a string containings words separated by spaces/tabs and
"   a:word is a one of those words.
" postconditions:
"   The next word after a:word in a:candidates is returned. If a:word is the
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
"   A string is returned. If a:word exists in database files, then the first
"   line containing a:word is returned, otherwise, an empty string is returned.
function! Ouroboros_candidates(word)
  for db in Ouroboros_databases()
    let l:candidates=matchstr(readfile(expand(db)), a:word)
    if strlen(l:candidates) > 0
      return l:candidates
    endif
  endfor
  return ''
endfunction

" preconditions:
"   a:str is a string without whitespaces ro tabulations.
" postconditions:
"   A replacement string is returned. If no replacement is found, an empty
"   string is returned.
function! Ouroboros_find(str)
    let l:candidates = Ouroboros_candidates(a:str)
    if strlen(l:candidates) > 0
      return Ouroboros_new_word(a:str,l:candidates)
    else
      return ''
    endif
endfunction

" preconditions:
"   a:str is a string.
" postconditions:
"   The word under the cursor is replaced by a:str.
function! Ouroboros_replace(str)
  exe "normal ciw" . a:str
endfunction

function! Is_upper(str)
  return a:str == toupper(a:str)
endfunction

function! Has_alpha(str)
  return match(a:str,'\a') != -1
endfunction

function! Start_with_upper(str)
  return match(a:str,'[A-Z]') == 0
endfunction

function! Capitalize(str)
  return toupper(a:str[0]) . a:str[1:]
endfunction

function! Minimalize(str)
  return tolower(a:str[0]) . a:str[1:]
endfunction

" Ouroboros entry point
"
" Replace the word under the cursor by the next word define in the first entry
" in the Ouroboros database files. If the word under the cursor is not define in
" Ouroboros database files, then nothing happens (a message is printed in vim
" footer notifying that no replacement has been found).
function! Ouroboros()
  try
    " retrieve word under cursor
    let l:old_word = expand("<cword>")

    " check for empty strings
    if strlen(l:old_word) == 0
      echo 'Ouroboros: cannot replace an empty string'
      return
    endif

    " look for direct candidates
    let l:new_word = Ouroboros_find(l:old_word)
    if strlen(l:new_word) > 0
      call Ouroboros_replace(l:new_word)
      return
    endif

    " look for upper case candidates
    if Has_alpha(l:old_word) && Is_upper(l:old_word)
      let l:new_word = toupper(Ouroboros_find(tolower(l:old_word)))
      if strlen(l:new_word) > 0
        call Ouroboros_replace(l:new_word)
        return
      endif
    endif

    " look for candidates with a leading uppercase letter only
    if Start_with_upper(l:old_word)
      let l:new_word = Capitalize(Ouroboros_find(Minimalize(l:old_word)))
      if strlen(l:new_word) > 0
        call Ouroboros_replace(l:new_word)
        return
      endif
    endif

    " no candidates found
    echo 'Ouroboros: no entry found for "' . l:old_word . '"'
  catch
    echo 'Ouroboros: ' . v:exception
  endtry
endfunction

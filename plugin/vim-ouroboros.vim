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
let s:default_database_filepath='' . s:this_plugin_root_dir . '/db/default.db'

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
  endif
endfunction

" preconditions:
"   a:word is a word (avoid special characters)
" postconditions:
"   A string is returned. If a:word exists in database files, then the first
"   line containing a:word is returned, otherwise, an empty string is returned.
function! Ouroboros_candidates(word)
  for db in Ouroboros_databases()
    let l:candidates=matchstr(readfile(expand(db)), '\(^\|.*\s\)'.a:word.'\(\s.*\|$\)')
    if strlen(l:candidates) > 0
      return l:candidates
    endif
  endfor
  return ''
endfunction

" preconditions:
"   a:str is a string without whitespaces or tabulations.
" postconditions:
"   A replacement string is returned. If no replacement is found, an empty
"   string is returned.
function! Ouroboros_find_straight(str)
  let l:candidates = Ouroboros_candidates(a:str)
  if strlen(l:candidates) > 0
    return Ouroboros_new_word(a:str,l:candidates)
  else
    return ''
  endif
endfunction

" preconditions:
"   a:str is a string without whitespaces or tabulations containing upper case
"   letters only and non-alphanumerical characters.
" postconditions:
"   A replacement string is returned. If no replacement is found, an empty
"   string is returned.
function! Ouroboros_find_upper(str)
  return toupper(Ouroboros_find_straight(tolower(a:str)))
endfunction

" preconditions:
"   a:str is a string without whitespaces or tabulations staring with a capital
"   letter.
" postconditions:
"   A replacement string is returned. If no replacement is found, an empty
"   string is returned.
function! Ouroboros_find_capital(str)
  return Capitalize(Ouroboros_find_straight(Minimalize(a:str)))
endfunction

" preconditions:
"   a:str is a string without whitespaces or tabulations.
" postconditions:
"   A replacement string is returned. If no replacement is found, an empty
"   string is returned.
function! Ouroboros_find(str)
  " look for direct match
  let l:replacement = Ouroboros_find_straight(a:str)
  if strlen(l:replacement) > 0
    return l:replacement
  endif

  " look for a match with upper case letters
  if Has_alpha(a:str) && Is_upper(a:str)
    let l:replacement = Ouroboros_find_upper(a:str)
    if strlen(l:replacement) > 0
      return l:replacement
    endif
  endif

  " look for a match with a leading uppercase letter only
  if Start_with_upper(a:str)
    let l:replacement = Ouroboros_find_capital(a:str)
    if strlen(l:replacement) > 0
      return l:replacement
    endif
  endif

  return ''
endfunction

" preconditions:
"   a:str is a string.
" postconditions:
"   The word under the cursor is replaced by a:str.
function! Ouroboros_replace(str)
  exe "normal ciw" . a:str . "\<Esc>`["
endfunction

" Return 1 if a:str contains uppercase letters only (and/or non-alpha
" characters), otherwise return 0.
function! Is_upper(str)
  return a:str == toupper(a:str)
endfunction

" Return 1 if a:str contains at least one alpha character, otherwise return 0.
function! Has_alpha(str)
  return match(a:str,'\a') != -1
endfunction

" Return 1 if a:str starts with an uppercase letter.
function! Start_with_upper(str)
  return match(a:str,'[A-Z]') == 0
endfunction

" Return a copy of a:str that starts with an upper case letter.
function! Capitalize(str)
  return toupper(a:str[0]) . a:str[1:]
endfunction

" Return a copy of a:str that starts with a lower case letter.
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

    let l:new_str = Ouroboros_find(l:old_word)
    if strlen(l:new_str) > 0
      call Ouroboros_replace(l:new_str)
      return
    endif

    " no candidates found
    echo 'Ouroboros: no entry found for "' . l:old_word . '"'
  catch
    echo 'Ouroboros: ' . v:exception
  endtry
endfunction

" preconditions:
"   a:type is either 'v' or 'char'. If a:type is 'v' then marks `<, `> must be
"   set. If a:type is 'char' then marks `[, `] must be set.
" postconditions:
"   Return a string containing the text captured marks `<, `> or `[, `]
"   depending on a:type.
function! Ouroboros_motion_get_text(type)
  let l:sel_save = &selection
  let &selection = "inclusive"
  let l:reg_save = @@

  if a:type ==# 'v'
    silent exe "normal! `<v`>y"
  elseif a:type ==# 'char'
    silent exe "normal! `[v`]y"
  else
    throw 'Ouroboros: linewise/blockwise replacements are not possible'
  endif

  let l:text = @@
  let &selection = l:sel_save
  let @@ = l:reg_save
  return l:text
endfunction

" preconditions:
"   a:type is either 'v' or 'char'. If a:type is 'v' then marks `<, `> must be
"   set. If a:type is 'char' then marks `[, `] must be set.
" postconditions:
"   Set the text inside marks `<, `> or `[, `] (depending on a:type) by a:text.
function! Ouroboros_motion_set_text(type,text)
  let l:sel_save = &selection
  let &selection = "inclusive"
  let l:reg_save = @@

  if a:type ==# 'v'
    silent exe "normal! `<v`>c".a:text."\<Esc>`<"
  elseif a:type ==# 'char'
    silent exe "normal! `[v`]c".a:text."\<Esc>`["
  else
    throw 'Ouroboros: linewise/blockwise motions are not possible'
  endif

  let l:text = @@
  let &selection = l:sel_save
  let @@ = l:reg_save
  return l:text
endfunction

" Ouroboros entry point for motion mapping
"
" Replace the text captured from a vim motion by the next word define in the
" first entry in the Ouroboros database files. If the text is not define in
" Ouroboros database files, then nothing happens (a message is printed in vim
" footer notifying that no replacement has been found).
function! Ouroboros_motion(type)
  try
    let l:old_text = Ouroboros_motion_get_text(a:type)
    " remove whitespaces at the start and the end
    let l:old_str = substitute(l:old_text,'\s\+$\|^\s\+','','g')
    " abort if the string contains whitespaces
    if match(l:old_str,'\s') != -1
      throw 'Ouroboros: using strings containing whitespaces is not possible'
    endif
    " look for a replacement
    let l:new_str = Ouroboros_find(l:old_str)
    if strlen(l:new_str) > 0
      " put back whitespaces at the start and the end
      let l:new_text = substitute(l:old_text,l:old_str,l:new_str,'')
      " change the text from the vim motion
      call Ouroboros_motion_set_text(a:type,l:new_text)
    else
      throw 'Ouroboros: no entry found for "' . l:old_str . '"'
    endif
  catch
    echo v:exception
  endtry
endfunction

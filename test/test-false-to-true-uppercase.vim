let test="replace 'FALSE' by 'TRUE'"

source test/utility.vim

try
  " load plugin
  set rtp+=.
  source ./plugin/vim-ouroboros.vim

  " setup initial state
  "   create database
  let lines= [
        \ 'true false',
        \ 'begin end',
        \ 'one two three'
        \ ]
  let db='/tmp/ouroboros_test_db'
  call writefile(lines,db)
  "   set path to database
  let g:ouroboros_db=[db]
  "   set mapping
  nmap <silent> , :call Ouroboros()<CR>
  "   set test line
  call setline(1, 'FALSE')
  call cursor(1,1)

  " perform operation
  normal ,

  " test the result
  let result = getline('.')
  let expected = "TRUE"
  if result == expected
    call Echo(test.' => success')
  else
    call Echo(test.' => failure (expected '.expected.' got '.result.')')
  endif
catch
  call Echo(test . ' => failure ('.v:exception.')')
endtry

quit!

# vim-ouroboros

Replace the word under the cursor by other words with related (often
symmetrical) meanings (e.g. true/false, begin/end, insert/remove,
one/two/three/four/..., ...). The replacement is performed cyclically based on a
list of words defined in a database file.

### How this plugin increases productivity?

Ouroboros can be used to quickly replace words after copy/paste operations. The
example below shows a method being copy/paste and renamed with Ouroboros.

```
class somethig_with_a_range_like_interface
{
public:
  // method written by hand and copied as a template to generate end()
  auto begin() {
    ...
  }

  // method pasted from begin()
  auto begin() {
    // ^ - 'begin' can be replaced by 'end' by hitting the Ouroboros shortcut
    ...
  }
};
```

Ouroboros can be used to quickly replace the type of a declaration by another
related type.

```
std::list<int> queue;
//   ^ - 'list' can be replaced by 'vector'
queue.push_back(0);
queue.push_back(1);
queue.push_back(2);
```

```
uint16_t x = 65536;
//     ^ - 'uint16_t' can be replaced by 'uint32_t'
```

Here is a non-exhaustive list of common replacement in C++
- true, false
- begin, end
- first, last
- public, protected, private
- class, struct
- front, back
- push_front, push_back
- pop_front, pop_back
- signed, unsigned
- float, double
- uint8_t, uint16_t, uint32_t, uint64_t
- int8_t, int16_t, int32_t, int64_t
- if, else
- ==, !=
- <, =<, >, =>
- vector, list

## Installation

Install using your favorite package manager, or use Vim's built-in package
support.

```
mkdir -p ~/.vim/pack/vim-ouroboros/start
cd ~/.vim/pack/vim-ouroboros/start
git clone git@github.com:Leo843/vim-ouroboros.git
vim -u NONE -c "helptags vim-ouroboros/doc" -c q
```

## Configuration

### How to define a mapping for Ouroboros

No default mapping is provided, one has to be defined (usually in `.vimrc`).
The entrypoint of the plugin is the function Ouroboros() and can be mapped as
shown below.

```
nmap <silent> <leader>o :call Ouroboros()<CR>
```

### How to set database files

Ouroboros uses files found in `g:ouroboros_db` to look for a replacement. This
list of files can be set in `.vimrc`. By default Ouroboros uses a default
database located at `<plugin-root>/db/ouroboros.db` (where `<plugin-root>` is
the root directory of the plugin and depends on the plugin manager).

```
let g:ouroboros_db=[
  \ 'path/to/first/db',
  \ 'path/to/second/db',
  ...
  \ ]
```

Each line in a database file defines a sequence of words (separated by at least
one space or tab). A word is always replaced by the next word of the first
sequence containing it (except for the last word which is replaced by the first
word of the sequence). Here is an example of such file.

```
true false
begin end
insert remove
zero one two three four five six seven eight nine
public protected private
start stop
```

> Files are looked over in the order in which they are defined in
> `g:ouroboros_db` or `b:ouroboros_db`. The lookup ends when the first occurence
> of the word being replaced is found (replacements for word can be shadowed if
> the word appears in multiple sequences in one or more files).

Databases can also be set per buffers with `b:ouroboros_db`. This allows the use
of different databases based on the `filetype` of the buffer (see `:h
ouroboros-database` for more information).

## Roadmap

[ ] Replace string starting with an upper case letter.
[ ] Replace string containing upper case letters only.
[ ] Handle text objects instead of words only.

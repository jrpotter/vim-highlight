Highlight
=========

[VERSION: 0.1]

Builds a custom registry for manipulating highlights. In particular, I found it
necessary to search for different keywords without overriding previous searches;
that is, I wanted to be able to continue adding more words to a search without
having to keep track of which words I've already searched for.

["x]&                               Highlights the <cword> under the cursor
                                    into register x.

["x]y&                              Sets the search register to the contents of
                                    register x.

["x]d&                              Removes the <cword> from register x.

["x]c&                              Emptys register x. No patterns previously
                                    belonging inside this register will be
                                    highlighted.

["x]*                               Highlights the <cword> under the cursor
                                    into register x. Moves to the next
                                    occurrence of the <cword>.

["x]#                               Highlights the <cword> under the cursor
                                    into register x. Moves to the previous
                                    occurrence of the <cword>.

["x]g&                              Highlights the <cword> under the cursor, but
                                    without forcing any highlighted occurrences
                                    to be a word. That is, if the selected
                                    <cword> is a substring of any text in the
                                    current buffer, the substring will also be
                                    highlighted.

["x]g*                              Works like ["x]g& but also moves to the next
                                    occurrence of the pattern.

["x]g#                              Works like ["x]g& but also moves to the
                                    previous occurrence of the pattern.

v_["x]&                             Note the v indicates visual mode. Works like
                                    g&, but with the visually selected region.

v_["x]*                             Note the v indicates visual mode. Works like
                                    g*, but with the visually selected region.

v_["x]#                             Note the v indicates visual mode. Works like
                                    g#, but with the visually selected region.

v_["x]d&                            Note the v indicates visual mode. Removes
                                    the visually selected region from register
                                    x.

Variables
---------

Refers to the color used for highlighting when a registry had not been initialized.

```
g:highlight_register_default_color = 'Yellow'
```

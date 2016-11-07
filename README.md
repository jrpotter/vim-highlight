Highlight
=========

[VERSION: 0.1]

Builds a custom registry for manipulating highlights. In particular, I found it
necessary to search for different keywords without overriding previous searches;
that is, I wanted to be able to continue adding more words to a search without
having to keep track of which words I've already searched for.

Functionality includes:

* ```["x]&```: Add the <cword> under the cursor into highlight registry ```x```.
* ```["x]d&```: Remove <cword> under the cursor from highlight registry ```x```.
* ```["x]c&```: Clear all words from highlight registry ```x```.

Additionally, overrides the following:

* ```["x]*```: Searches for the next <cword> and appends word into registry ```x```.
* ```["x]#```: Searches for the previous <cword> and appends word into registry ```x```.

Variables
---------

Refers to the color used for highlighting when a registry had not been initialized.

```
g:highlight_register_default_color = 'Yellow'
```

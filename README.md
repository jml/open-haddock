# open-haddock

_Quickly open documentation for Haskell packages or modules from the command
line_

## Motivation

This is for any Haskell programmer who has wanted to:

* look up documentation while offline
* find the documentation for the version of the package they actually have,
  rather than whatever the latest version happens to be

In particular, if you use nix or cabal sandboxes, this is the command-line
tool for you.

All you have to do is run `open-haddock` followed by either the name of a
package (e.g. `text`) or the name of a module (e.g. `Control.Monad`).


## Examples

```
$ open-haddock Data.Text
<browser opens local documentation for Data.Text>
```

```
$ open-haddock text
<browser opens local documentation for text package>
```

```
$ open-haddock --dry-run Turtle.Options
/nix/store/n3rgkskgjdph4ykqi845z5ayspzqbfqr-turtle-1.2.2/share/doc/x86_64-osx-ghc-7.10.2/turtle-1.2.2/html/Turtle-Options.html
```

```
$ open-haddock --dry-run turtle
/nix/store/n3rgkskgjdph4ykqi845z5ayspzqbfqr-turtle-1.2.2/share/doc/x86_64-osx-ghc-7.10.2/turtle-1.2.2/html/index.html
```

## Installation

Download the source from https://github.com/jml/open-haddock/ and install
using either `cabal` or `nix`.

Kusanagi
========

[![Build](https://github.com/DanielXMoore/kusanagi/actions/workflows/build.yml/badge.svg)](https://github.com/DanielXMoore/kusanagi/actions/workflows/build.yml)

The initial work on this project was funded by the [Origyn Foundation](https://origyn.ch).

CoffeeScript style syntax for the Motoko language. [Try Kusanagi](https://danielx.net/kusanagi/)

```motoko
import State "State"

module
  public class Grid(state : State.State)
    let grid = state

    let n = grid.size()

    public func size() : Nat
      n

    func nextCell(i : Nat, j : Nat) : State.Cell
      let l : Nat = living i, j
      if get i, j
        l == 2 or l == 3
      else
        l == 3

    func next(dst : Grid)
      for i in grid.keys()
        let cool = true

        for j in grid[i].keys()
          let yo = "wat"
          dst.set i, j, nextCell i, j

```

Features
---

- Indentation based blocks
- Let shorthand `x = 5` -> `let x = 5`
- Alternative with syntax
```
let x = {
  ...a
  ...b
}
```
becomes
```
let x = {
  a and
  b
}
```

Getting Started
---------------

Repo setup:
```bash
git clone git@github.com:DanielXMoore/kusanagi.git
cd kusanagi
yarn
yarn build
```

Basic demo:

```bash
./dist/kusanagi < test/examples/Basic.ku
```

Directory Structure
-------------------

```text
.github/workflows
  build.yml        # GitHub.com continuous integration testing
source/
  cli.coffee       # Basic command line wrapper
  generate.coffee  # Code generation
  kusanagi.hera    # Parsing expression grammar for Kusanagi of an extension of the Motoko language that provides indentation and whitespace based syntax
  motoko.hera      # Parsing expression grammar for the Motoko language based off of grammar.txt for testing and verifing the correct parsing of Motoko syntax
test/
  examples/        # Example .mo and .ku files for testing parsing and transpilation.
  *.coffee         # Test cases
grammar.txt        # Motoko language reference
NOTES.md           # Development notes useful for working on this software.
README.md          # This document
```

Motoko References
-----------------

- [GitHub Repo](https://github.com/dfinity/motoko)
- [Partial Grammar](https://github.com/dfinity/motoko/blob/master/doc/modules/language-guide/examples/grammar.txt)
- [Language Manual](https://github.com/dfinity/motoko/blob/master/doc/modules/language-guide/pages/language-manual.adoc)
- [Playground](https://m7sm4-2iaaa-aaaab-qabra-cai.raw.ic0.app/)
- [Embed Motoko](https://embed.smartcontracts.org/)

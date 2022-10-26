Development Notes
=================

These are technical development notes that will be of interest for anyone building or maintaining
this software.

Developing in this Repo
-----------------------

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

Fun Facts
---

Motoko allows to skip parens for a single function argument.

```motoko
Option.isSome result;//valid!
```

Eliminating Left Recursion
---

Bottom up parsers prefer left recursion, top down don't. Hera currently can't handle it.

This is a summary of the transformation to replace left recursion with iteration and is
applicable to any PEG style parser.

```text
A -> Aα | β
A -> β A' and A' -> α A' | ε
```

```hera
ExpBin
  ExpUn # β
  # Left recursion will blow up since hera parses top down
  ExpBin Binop ExpBin
  ExpBin Relop ExpBin
  ExpBin "and" ExpBin
  ExpBin "or" ExpBin
  ExpBin ":" TypNobin
```

```hera
ExpBin
  # Left recursion converted to iteration
  # β A'
  ExpUn ExpBinRest*

ExpBinRest # A '
  Binop ExpBin
  Relop ExpBin
  "and" ExpBin
  "or" ExpBin
  ":" TypNobin
```

Prevent Shadowing
---

Non-PEG grammars try all rules to construct a successful parse. PEG grammars try each rule in sequence. If the first
rule will always succeed then no following rules will be tried. Re-ordering the rules to prevent shadowing is necessary.

```hera
Vis
  Empty # This will always match
  "private"
  "public"
  "system"
```

```hera
Vis
  "private"
  "public"
  "system"
  Empty # Move to the bottom to prevent shadowing
```

```hera
PatField # Same idea
  Id (__ ":" __ Typ)?
  Id (__ ":" __ Typ)? __ "=" __  Pat
```

```hera
PatField
  Id (__ ":" __ Typ)? __ "=" __  Pat
  Id (__ ":" __ Typ)?
```

Could also use option to reduce backtracking

```hera
PatField
  Id (__ ":" __ Typ)? ( __ "=" __  Pat)?
```

Explicit Whitespace
---

Since the Motoko parser is _generally_ implicit about whitespace that makes it very hard to make an indentation sensitive dialect.
Being explicit about where whitespace is consumed allows us to use indentation and whitespace explicitly to define structure. The
first step is to add in `__` which consumes any or no whitespace and comments (essentially the implicit ignoring whitespace behavior)
but made explicit.

```hera
PatField
  Id ( ":" Typ)? ( "=" Pat)?
```

```hera
PatField
  Id (__ ":" __ Typ)? ( __ "=" __  Pat)?
```

The next step is to add additional constructions specifying explicit indentation behavior where useful. [See `NestedExpressions` for a preview](./source/experiments.hera)

Convert Markdown Table to CSV
---

```bash
sed 's/^|//;s/|/,/g;/--/d'
```

Adding Package to Motoko Compiler CLI
---

If importing a package in a motoko file like:

```motoko
import Debug "mo:base/Debug";

// ...
```

Then the `moc` cli will need to know about it. Assuming the repo here https://github.com/dfinity/motoko-base has been cloned into pkg/ this will point the `moc` cli to the correct package

`moc --package base pkg/motoko-base/src ...`

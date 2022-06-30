Kusanagi
========

[![Build](https://github.com/DanielXMoore/kusanagi/actions/workflows/build.yml/badge.svg)](https://github.com/DanielXMoore/kusanagi/actions/workflows/build.yml)

CoffeeScript style syntax for the Motoko language.

Getting Started
---------------

Basic demo:

```bash
yarn
cat test/examples/Basic.ku
./source/cli.coffee < test/examples/Basic.ku
```

Starting out with a very hacky line by line approach. Expanding into a complete parser with test cases.

Directory Structure
-------------------

```text
.github/workflows
  build.yml        # GitHub.com continuous integration testing
source/
  cli.coffee       # Basic command line wrapper
  experiments.hera # Stripped down toy language to test out grammar constructs
  generate.coffee  # Code generation
  kusanagi.hera    # Parsing expression grammar for Kusanagi of an extension of the Motoko language that provides indentation and whitespace based syntax
  motoko.hera      # Parsing expression grammar for the Motoko language based off of grammar.txt for testing and verifing the correct parsing of Motoko syntax
  parser.hera      # Hacky indentation based proof of concept with no knowledge of Motoko language structure.
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

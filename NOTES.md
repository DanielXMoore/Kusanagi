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

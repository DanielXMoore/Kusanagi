Development Notes
=================

These are technical development notes that will be of interest for anyone building or maintaining
this software.

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

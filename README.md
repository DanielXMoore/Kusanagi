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

Get Started
---

```bash
npm install -g kusanagi
kusanagi < src.ku > out.mo
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
- Chained comparisons
```
x < y <= z
---
x < y and y <= z
```
- `match`
```
match x, #nat(val), 0
---
switch(x) {
  case(#nat(val)) { val };
  case(_){ 0 }
};
```
- `take`
```
take x, 0
---
switch(x) {
  case(null) { 0 };
  case(?val) { val }
};
```
- Null soaks
```
student.classes?.get(classID)
---
do?{student.classes!.get(classID)};
```

#!/bin/bash
set -euox pipefail

# Testing .ku -> .mo -> .wasm

for KU in `ls test/examples/*.ku`; do
  FILE=${KU#test/examples/}
  NAME=${FILE%.ku}

  MO=integration/$NAME.mo
  WASM=integration/$NAME.wasm

  coffee --nodejs '-r ../hera/register' ./source/cli.coffee < $KU > $MO
  moc -c --package base pkg/motoko-base/src/ -o $WASM < $MO

done

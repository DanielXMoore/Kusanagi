{parse} = require "./kusanagi"
generate = require "./generate"

encoding = "utf8"
fs = require "fs"

input = fs.readFileSync process.stdin.fd, encoding

ast = parse input,
  verbose: process.argv.includes "--verbose"

if process.argv.includes "--ast"
  process.stdout.write JSON.stringify(ast, null, 2)
  return

output = generate ast
process.stdout.write output

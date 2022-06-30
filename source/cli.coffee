#!./node_modules/.bin/coffee

require "@danielx/hera/register"

{parse} = require "./kusanagi"
generate = require "./generate"

encoding = "utf8"
fs = require "fs"

input = fs.readFileSync process.stdin.fd, encoding

ast = parse input
output = generate ast

process.stdout.write output

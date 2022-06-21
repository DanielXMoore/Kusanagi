#!./node_modules/.bin/coffee

require "@danielx/hera/register"

parser = require './parser'
encoding = "utf8"
fs = require "fs"

input = fs.readFileSync process.stdin.fd, encoding

process.stdout.write parser.parse(input)

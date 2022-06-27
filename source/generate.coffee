require "@danielx/hera/register"

fs = require "fs"

{parse} = require "./motoko"

generate = (node) ->
  if typeof node is "string"
    return node

  if Array.isArray node
    return node.map (item) ->
      generate(item)
    .join("")

  return "<UNKNOWN #{JSON.stringify(node)} >"

console.log(generate(parse(fs.readFileSync("./test/examples/Alarm.mo", "utf8"))))

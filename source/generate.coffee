###*
Transpile the Kusanagi source tokens to Motoko source strings.

Most of the modifications happen in the parser and eventually this will be nearly empty.

Generate receives an array of tokens and for each one recursively concatenates it.

`null` and undefined are `converted` to the empty string.

literal strings are kept exactly as is.

Arrays are iterated, recursively generated, and joined together as strings.

Objects with a `type` field may have a special handling.

The "AST" is currently just nested arrays of string tokens for the most part. The custom type objects
are very useful for debugging though. Some may need to be added back for more complex transformations
as well, but since this is trying to be a very 1 to 1 transpiler most things should be fine as strings
with minor insertions or adjustments from the parser.
###
generate = (node) ->
  gen = (item) ->
    generate(item)

  if typeof node is "string"
    return node

  if Array.isArray node
    return node.map gen
    .join("")

  if node is undefined or node is null
    return ""

  return switch node.type
    when "block"
      {decs, pre, afterOpen, beforeClose} = node

      if decs.length
        code = decs.map(gen)

        "#{gen(pre)}{#{gen(afterOpen)}#{code.join(";")}#{gen(beforeClose)}}"
      else
        "#{gen(pre)}{#{gen(afterOpen)}#{gen(beforeClose)}}"

    when "typetag"
      {id, suffix} = node

      "#{gen(id)}#{gen(suffix)}"

    when "break", "continue"
      # TODO: More accurate whitespace
      "#{node.type}#{gen(node.exp)}"

    when "label"
      throw new Error "TODO: type: label"

    when "parens"
      {pre, exps, beforeClose} = node
      gen [
        pre
        "("
        # TODO: handle comments and whitespace around separators
        exps.map(gen).join(", ")
        beforeClose
        ")"
      ]

    else
      "<UNKNOWN #{JSON.stringify(node)} >"

module.exports = generate

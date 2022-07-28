indentation = "  "

generate = (node, indent="") ->
  gen = (item) ->
    generate(item, indent)

  if typeof node is "string"
    return node

  if Array.isArray node
    return node.map gen
    .join("")

  if node is undefined or node is null
    return ""

  return switch node.type
    when "actor", "module", "object"
      {type, id, body} = node

      [type, id, body].map(gen).join("")

    when "block"
      {decs, pre, afterOpen, beforeClose} = node

      if decs.length
        code = decs.map(gen)

        "#{gen(pre)}{#{gen(afterOpen)}#{code.join(";")}#{gen(beforeClose)}}"
      else
        "#{gen(pre)}{#{gen(afterOpen)}#{gen(beforeClose)}}"

    when "dec"
      {prefix, dec} = node

      "#{prefix}#{gen(dec)}"

    when "typefield"
      {prefix, id, suffix} = node

      "#{gen(prefix)}#{gen(id)}#{gen(suffix)}"

    when "typetag"
      {id, suffix} = node

      "#{gen(id)}#{gen(suffix)}"

    when "await", "return", "break", "continue", "debug", "throw", "ignore"
      # TODO: More accurate whitespace
      "#{node.type}#{gen(node.exp)}"

    when "expbin"
      {exps} = node

      gen exps

    when "binassign"
      {base, op, exp} = node
      "#{gen(base)} #{op} #{gen(exp)}"

    when "label"
      throw new Error "TODO: type: label"

    when "func"
      {id, pat, body, shared, typeSuffix, typing} = node

      "#{shared}func#{id}#{gen(typing)}#{gen(pat)}#{gen(typeSuffix)}#{gen(body)}"

    when "if"
      {exp, condition, elseBlock} = node

      "if#{gen(condition)}#{gen(exp)}#{gen(elseBlock)}"

    when "for"
      {pat, source, exp} = node

      "for (#{gen(pat)} in #{gen(source)})#{gen(exp)}"

    when "do"
      {block, option} = node

      if option
        "do ? #{gen(block)}"
      else
        "do #{gen(block)}"

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

    when "="
      {id, exp} = node

      if id
        "= #{id} #{gen(exp)}"
      else
        "= #{gen(exp)}"

    else
      "<UNKNOWN #{JSON.stringify(node)} >"

module.exports = generate

indentation = "  "

generate = (node, indent="") ->
  gen = (item) ->
    generate(item, indent)
  genNested = (item) ->
    generate(item, indent + indentation)

  if typeof node is "string"
    return node

  if Array.isArray node
    return node.map gen
    .join("")

  if node is undefined or node is null
    return ""

  return switch node.type
    when "program"
      {decs, post} = node
      decs.map(gen).join(";") + post

    when "import"
      {pre, pat, source} = node

      "#{pre}import #{gen(pat)} #{gen(source)}"

    when "actor", "module", "object"
      {type, id, body} = node

      [type, id, body].map(gen).join("")

    when "array"
      {exps, prefix, beforeClose} = node

      if exps.length
        code = exps.map(genNested)

        "[#{prefix}\n" + code.join(",") + "#{gen(beforeClose)}]"
      else
        "[#{prefix}]"

    when "block"
      {decs, pre, afterOpen, beforeClose} = node

      if decs.length
        code = decs.map(genNested)

        "#{gen(pre)}{#{gen(afterOpen)}#{code.join(";")}#{gen(beforeClose)}}"
      else
        "#{gen(pre)}{#{gen(afterOpen)}#{gen(beforeClose)}}"

    when "dec"
      {prefix, dec} = node

      "#{prefix}#{gen(dec)}"

    when "let"
      {pat, exp} = node

      "let #{gen(pat)} = #{gen(exp)}"

    when "var"
      {id, exp, typeSuffix} = node

      "var #{id}#{typeSuffix} = #{gen(exp)}"

    when "typebind"
      {binds} = node
      bindings = binds.map gen
      .join(", ")

      "<#{bindings}>"

    when "typedec"
      {beforeEq, id, typing, exp} = node

      "type#{gen(id)}#{gen(typing)}#{gen(beforeEq)}=#{gen(exp)}"

    when "typefield"
      {prefix, id, suffix} = node

      "#{gen(prefix)}#{gen(id)}#{gen(suffix)}"

    when "typetag"
      {id, suffix} = node

      "#{gen(id)}#{gen(suffix)}"

    when "type"
      {id, typArgs} = node

      "#{id}#{gen(typArgs)}"

    when "exppost"
      {base, rest} = node

      gen([base, rest])

    when "projection"
      ".#{node.id}"

    when "application"
      {fnArgs, typArgs} = node

      gen([typArgs, fnArgs])

    when "assert", "async", "await", "return", "break", "continue", "debug", "throw", "ignore"
      # TODO: More accurate whitespace
      "#{node.type} #{gen(node.exp)}"

    when "expbin"
      {exps} = node

      gen exps

    when "binassign"
      {base, op, exp} = node
      "#{gen(base)} #{op} #{gen(exp)}"

    when "label"
      throw new Error "TODO: type: label"

    when "class"
      {id, sort, pat, body, shared, typeSuffix, typing} = node

      gen [
        shared
        sort
        "class"
        id
        typing
        pat
        typeSuffix
        body
      ]

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

    when "index"
      {exp} = node
      "[#{gen(exp)}]"

    when "parens"
      {pre, exps} = node
      [gen(pre), "(", exps.map(gen).join(", "), ")"].join("")

    when "="
      {id, exp} = node

      if id
        "= #{id} #{gen(exp)}"
      else
        "= #{gen(exp)}"

    when "switch"
      {condition, cases} = node

      "switch#{gen(condition)}#{gen(cases)}"

    when "case", "catch"
      {type, pat, exp, pre} = node
      "#{gen(pre)}#{type} #{gen(pat)}#{gen(exp)}"

    when "try"
      {exp, catch:c, pre} = node

      """
        try#{gen(exp)}#{gen(pre)}#{gen(c)}
      """

    when "loop"
      {exp, whileBlock} = node

      "loop#{gen(exp)}#{gen(whileBlock)}"
    else
      "<UNKNOWN #{JSON.stringify(node)} >"

module.exports = generate

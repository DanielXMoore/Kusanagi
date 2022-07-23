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
      {decs} = node
      decs.map(gen).join(";")

    when "import"
      {pre, pat, source} = node

      "#{pre}import #{gen(pat)} #{gen(source)}"

    when "actor", "module", "object"
      {type, id, body} = node

      code = [type]

      if id
        code.push " ", id

      code.push " ", genNested(body)
      code.join("")

    when "array"
      {exps, prefix} = node

      if exps.length
        code = exps.map(genNested)

        "[#{prefix}\n#{indent}" + code.join(",\n#{indent}") + "\n#{indent.slice(0, -2)}]"
      else
        "[#{prefix}]"

    when "block"
      {decs} = node

      if decs.length
        code = decs.map(genNested)

        "{\n#{indent}" + code.join(";\n#{indent}") + "\n#{indent.slice(0, -2)}}"
      else
        "{}"

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
      {id, typing, exp} = node

      # TODO: Fix indentation
      "type#{id}#{gen(typing)} = #{genNested(exp)}"

    when "typefield"
      {prefix, id, suffix} = node

      "#{prefix}#{id} : #{gen(suffix)}"

    when "typetag"
      {id, suffix} = node

      if suffix
        "#{id}: #{gen(suffix)}"
      else
        id

    when "type"
      {id, typArgs} = node

      "#{id}#{gen(typArgs)}"

    when "exppost"
      {base, rest} = node

      "#{base}#{rest.map(gen).join("")}"

    when "projection"
      ".#{node.id}"

    when "application"
      {fnArgs, typArgs} = node
      typeBinding = gen(typArgs)

      result = if fnArgs.type is "parens"
        gen(fnArgs)
      else
        " #{gen(fnArgs)}"

      "#{typeBinding}#{result}"

    when "assert", "async", "await", "return", "break", "continue", "debug", "throw", "ignore"
      "#{node.type} #{gen(node.exp)}"

    when "expbin"
      {exps} = node
      i = 1

      code = [gen(exps[0])]

      while i < exps.length
        code.push exps[i], gen(exps[i+1])
        i += 2

      code.join(" ")

    when "binassign"
      {base, op, exp} = node
      "#{gen(base)} #{op} #{gen(exp)}"

    when "label"
      throw new Error "TODO: type: label"

    when "class"
      {id, sort, pat, body, shared, typeSuffix, typing} = node

      if pat.type is "parens"
        pat = gen(pat)
      else
        pat = " #{gen(pat)}"

      ["#{shared}#{sort}class", "#{id}#{gen(typing)}", pat, typeSuffix, gen(body)]
      .join(" ")

    when "func"
      {id, pat, body, shared, typeSuffix, typing} = node

      if pat.type is "parens"
        pat = gen(pat)
      else
        pat = " #{gen(pat)}"

      ["#{shared}func", "#{id}#{gen(typing)}", pat, typeSuffix, gen(body)]
      .join(" ")

    when "if"
      {exp, condition, elseBlock} = node
      if elseBlock
        """
          if #{gen(condition)} #{gen(exp)}
          #{indent.slice(0, -2)}else #{gen(elseBlock)}
        """
      else
        "if #{gen(condition)} #{gen(exp)}"

    when "for"
      {pat, source, exp} = node

      "for (#{gen(pat)} in #{gen(source)}) #{gen(exp)}"

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
      ["(", node.exps.map(gen).join(", "), ")"].join("")

    when "="
      {id, exp} = node

      if id
        "= #{id} #{gen(exp)}"
      else
        "= #{gen(exp)}"

    when "switch"
      {condition, cases} = node

      """
        switch #{gen(condition)} {
        #{indent}#{cases.map(genNested).join(";\n#{indent}")}
        #{indent.slice(0, -2)}}
      """

    when "case", "catch"
      {type, pat, exp} = node
      "#{type} #{gen(pat)} #{gen(exp)}"

    when "try"
      {exp, catch:c} = node

      """
        try #{gen(exp)}
        #{indent.slice(0, -2)}#{gen(c)}
      """

    when "loop"
      {exp, whileBlock} = node
      if whileBlock
        """
          loop #{gen(exp)}
          #{indent.slice(0, -2)}while #{gen(whileBlock)}
        """
      else
        """
          loop #{gen(exp)}
        """
    else
      "<UNKNOWN #{JSON.stringify(node)} >"

module.exports = generate

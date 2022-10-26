{ compare } = require "./helper"

describe "match", ->
  it "adds switch with case, no parens", ->
    compare """
      let x: Nat = match x, #nat(val), 0
    """, """
      let x: Nat = switch(x){case(#nat(val)){val};case(_){0}};
    """

  it "adds switch with case, with parens", ->
    compare """
      let x: Nat = match(x, #nat(val), 0)
    """, """
      let x: Nat = switch(x){case(#nat(val)){val};case(_){0}};
    """

  it "works with expressions", ->
    compare """
      let x = match aResult, #ok(val), return #err(debug_show(aResult))
    """, """
      let x = switch(aResult){case(#ok(val)){val};case(_){return #err(debug_show(aResult))}};
    """

  it "with null soaks", ->
    compare """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text>
        return #ok(match student.classes?.get(classID), #ok(val), return #err "not found")
    """, """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text> {
        return #ok(switch(do?{student.classes!.get(classID)}){case(#ok(val)){val};case(_){return #err "not found"}});
      };
    """

describe "matchr", ->
  it "adds switch with case, no parens", ->
    compare """
      let x: Nat = matchr x, #nat(val), 0
    """, """
      let x: Nat = switch(x){case(#ok(val)){#nat(val)};case(#err(err)){0}};
    """

  it "adds switch with case, with parens", ->
    compare """
      let x: Nat = matchr(x, #nat(val), 0)
    """, """
      let x: Nat = switch(x){case(#ok(val)){#nat(val)};case(#err(err)){0}};
    """

  it "works with expressions", ->
    compare """
      let x = matchr aResult, #nat(val), return #err(debug_show(aResult))
    """, """
      let x = switch(aResult){case(#ok(val)){#nat(val)};case(#err(err)){return #err(debug_show(aResult))}};
    """

  it "with null soaks", ->
    compare """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text>
        return #ok(matchr student.classes?.get(classID), #nat(val), return #err "not found")
    """, """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text> {
        return #ok(switch(do?{student.classes!.get(classID)}){case(#ok(val)){#nat(val)};case(#err(err)){return #err "not found"}});
      };
    """

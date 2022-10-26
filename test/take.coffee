{ compare } = require "./helper"

describe "take", ->
  it "adds switch with a default value, no parens", ->
    compare """
      take x, 0
    """, """
      switch(x){case(null){0};case(?val){val}};
    """

  it "adds switch with a default value, with parens", ->
    compare """
      take(x, 0)
    """, """
      switch(x){case(null){0};case(?val){val}};
    """

  it "with null soaks", ->
    compare """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text>
        return #ok take(student.classes?.get(classID), return #err "not found")
    """, """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text> {
        return #ok(switch(do?{student.classes!.get(classID)}){case(null){return #err "not found"};case(?val){val}});
      };
    """

  it "with null soaks", ->
    compare """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text>
        return #ok(take student.classes?.get(classID), return #err "not found")
    """, """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text> {
        return #ok(switch(do?{student.classes!.get(classID)}){case(null){return #err "not found"};case(?val){val}});
      };
    """

  it "with null soaks", ->
    compare """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text>
        return #ok take student.classes?.get(classID), return #err "not found"
    """, """
      func findStudentClass(student: Student, classId : Nat) : Result<ClassType, Text> {
        return #ok(switch(do?{student.classes!.get(classID)}){case(null){return #err "not found"};case(?val){val}});
      };
    """

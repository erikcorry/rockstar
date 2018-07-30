class Statement {
  String indentation(int indent, String newline) {
    if (newline == "") return "";
    return new String.fromCharCodes(new Iterable.generate(indent, (n) => 32));
  }
  String toString() => dump(0, "");
}

class Expression extends Statement {
}

class Constant extends Expression {
}

class Oddball extends Constant {
  Oddball(this.name);
  String name;
  String dump(int indent, String nl) => "${indentation(indent, nl)}($name)$nl";
}

class IntegerConstant extends Constant {
  IntegerConstant(this.integer);
  int integer;
  String dump(int indent, String nl) => "${indentation(indent, nl)}($integer)$nl";
}

class FloatConstant extends Constant {
  FloatConstant(this.float);
  double float;
  String dump(int indent, String nl) => "${indentation(indent, nl)}($float)$nl";
}

class StringConstant extends Constant {
  StringConstant(this.string);
  String string;
  String dump(int indent, String nl) => "${indentation(indent, nl)}(\"$string\")$nl";
}

class Binary extends Expression {
  Binary(this.left, this.operator, this.right);
  Expression left;
  String operator;
  Expression right;
  String dump(int indent, String nl) {
    List<String> lines = [];
    lines.add("${indentation(indent, nl)}($operator$nl");
    lines.add(left.dump(indent + 2, nl));
    lines.add(right.dump(indent + 2, nl));
    lines.add("${indentation(indent, nl)})$nl");
    return lines.join("");
  }
}

class Variable extends Expression {
  String name;
  factory Variable(Map symbol_table, Map top_level, String name) {
    if (symbol_table != null && symbol_table.containsKey(name)) return symbol_table[name];
    if (top_level.containsKey(name)) return top_level[name];
    _error("Unknown variable: $name");
  }

  Variable.create(Map symbol_table, this.name) {
    if (!(name is String) || name == '"') _error("Variable name invalid");
    if (symbol_table.containsKey(name)) _error("Two variables called $name");
    symbol_table[name] = this;
  }

  String dump(int indent, String nl) => "${indentation(indent, nl)}($name)$nl";
}

class Initialization extends Statement {
  Initialization(this.variable, this.initial_value);
  Variable variable;
  Constant initial_value;
  String dump(int indent, String nl) {
    List<String> lines = [];
    lines.add("${indentation(indent, nl)}(Initialize$nl");
    lines.add(variable.dump(indent + 2, nl));
    lines.add(initial_value.dump(indent + 2, nl));
    lines.add("${indentation(indent, nl)})$nl");
    return lines.join("");
  }
}

class Assignment extends Statement {
  Assignment(this.variable, this.expression);
  Variable variable;
  Expression expression;
  String dump(int indent, String nl) {
    List<String> lines = [];
    lines.add("${indentation(indent, nl)}(Assign$nl");
    lines.add(variable.dump(indent + 2, nl));
    lines.add(expression.dump(indent + 2, nl));
    lines.add("${indentation(indent, nl)})$nl");
    return lines.join("");
  }
}

class Listen extends Statement {
  Listen(this.variable);
  Variable variable;
  String dump(int indent, String nl) {
    List<String> lines = [];
    lines.add("${indentation(indent, nl)}(Listen$nl");
    lines.add(variable.dump(indent + 2, nl));
    lines.add("${indentation(indent, nl)}$nl");
    return lines.join("");
  }
}

class ConditionStatement extends Statement {
  String name;  // "if", "while" or "until".
  Expression condition;
  List<Statement> statements = [];

  ConditionStatement(this.name, this.condition);
  String dump(int indent, String nl) {
    List<String> lines = [];
    lines.add("${indentation(indent, nl)}($name$nl");
    lines.add(condition.dump(indent + 2, nl));
    for (var s in statements) lines.add(s.dump(indent + 2, nl));
    lines.add("${indentation(indent, nl)})$nl");
    return lines.join("");
  }
}

class Return extends Statement {
  Return(this.expression);
  Expression expression;
  String dump(int indent, String nl) {
    List<String> lines = [];
    lines.add("${indentation(indent, nl)}(return$nl");
    lines.add(expression.dump(indent + 2, nl));
    lines.add("${indentation(indent, nl)})$nl");
    return lines.join("");
  }
}

class BreakContinue extends Statement {
  BreakContinue(this.name);
  String name;
  String dump(int indent, String nl) => "${indentation(indent, nl)}($name)$nl";
}

class Block extends Statement {
  Block();
  List<Statement> statements = [];
  String dump(int indent, String nl) {
    List<String> lines = [];
    for (Statement s in statements) lines.add(s.dump(indent, nl));
    return lines.join("");
  }
}

var oddballs = {
  "null": new Oddball("null"),
  "true": new Oddball("true"),
  "false": new Oddball("false"),
  "mysterious": new Oddball("mysterious")
};

class RockstarFunction {
  int arity;
  String name;

  RockstarFunction(this.arity, this.name);
}

class UserFunction extends RockstarFunction {
  Map<String, Variable> locals;
  List<Statement> statements = [];

  UserFunction(String name, Map<String, Variable> l) : super(l.length, name) {
    locals = l;
  }

  String dump(String nl) {
    List<String> lines = [];
    String ind = nl == "" ? "" : "  ";
    lines.add("(function $name($nl");
    for (String l in locals.keys) {
      lines.add("$ind$ind($l)$nl");
    }
    lines.add("$ind)$nl");
    for (Statement s in statements) {
      lines.add(s.dump(2, nl));
    }
    lines.add(")$nl");
    return lines.join("");
  }

  String toString() => dump("");
}

class NativeFunction extends RockstarFunction {
  NativeFunction(int arity, String name) : super(arity, name) {}
  evaluate(List arguments);
}

class FunctionInvocation extends Expression {
  RockstarFunction fn;
  List<Expression> arguments = [];

  FunctionInvocation(this.fn);

  String dump(int indent, String nl) {
    List<String> lines = [];
    lines.add("${indentation(indent, nl)}${fn.name}($nl");
    for (Expression e in arguments) lines.add(e.dump(indent + 2, nl));
    lines.add("${indentation(indent, nl)})$nl");
    return lines.join("");
  }
}

class Say extends NativeFunction {
  Say() : super(1, "say") {}
  evaluate(List arguments) {
    print(arguments[0]);
  }
}

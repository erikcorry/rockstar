import "lexer.dart";

main() {
  var p = new Parser("""
Midnight takes your heart and your soul
While your heart is as high as your soul
Put your heart without your soul into your heart

Give back your heart


Desire is a lovestruck ladykiller
My world is nothing 
Fire is ice
Hate is water
Until my world is Desire,
Build my world up
If Midnight taking my world, Fire is nothing and Midnight taking my world, Hate is nothing
Shout \"FizzBuzz!\"
Take it to the top

If Midnight taking my world, Fire is nothing
Shout \"Fizz!\"
Take it to the top

If Midnight taking my world, Hate is nothing
Say \"Buzz!\"
Take it to the top

Whisper my world""");
  p.parse();
}

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

class Parser {
  Lexer _lexer;
  Block _ast = new Block();
  Map<String, RockstarFunction> _functions = {};
  Map<String, Variable> _top_level = {};
  Map<String, Variable> _function_level = null;
  Map<String, int> _prescedence_table;
  RockstarFunction _say;

  Parser(String program) {
    _lexer = new Lexer(program);
    _say = new Say();
    _prescedence_table = {
      "times": 5,
      "by": 5,
      "plus": 4,
      "minus": 4,
      "is": 2,
      "is not": 2,
      "is greater than": 1,
      "is less then": 1,
      "is as great as": 1,
      "is as low as": 1,
      "and": 0,
      "or": 0
    };
  }

  void parse() {
    while (_lexer.current != null) {
      Declaration s = parseDeclaration();
      if (s != null) {  // Blank line.
        if (s is RockstarFunction) {
          _functions[s.name] = s;
        } else {
          assert(s is Statement);
          _ast.statements.add(s);
        }
      }
    }
    for (String name in _functions.keys) {
      print(_functions[name].dump("\n"));
    }
    print(_ast.dump(0, "\n"));
  }

  void _error(message) {
    _lexer.error(message);
    throw message;
  }

  parseDeclaration() {
    if (_lexer.accept("put")) return parseAssignment();
    if (_lexer.accept("build")) return parseIncrement();
    if (_lexer.accept("knock")) return parseDecrement();
    if (_lexer.current == "continue") return new BreakContinue(_lexer.getNext);
    if (_lexer.current == "break") return new BreakContinue(_lexer.getNext);
    if (_lexer.current == "if") return parseConditional();
    if (_lexer.current == "while") return parseConditional();
    if (_lexer.current == "until") return parseConditional();
    if (_lexer.accept("say")) return parseSay();
    if (_lexer.accept("listen")) return parseListen();
    if (_lexer.accept("give back")) return parseReturn();
    if (_lexer.accept("\n")) return null;
    if (_functions.containsKey(_lexer.current)) return parseFunctionCall();
    var first = _lexer.getNext;
    if (_lexer.accept("takes")) return parseFunctionDeclaration(first);
    if (_lexer.current == "is") return parseInitialization(first);
    if (_lexer.current == "says") return parseInitialization(first);

    // Statement must be an expression.
    Expression e = expressionFromFirst(first);
    return parseRestOfExpression(e, 0);
  }

  Initialization parseInitialization(first) {
    _lexer.accept("is");
    var constant = parseExpression(0);
    if (!(constant is Constant)) _error("Initialization must be with a constant");
    // TODO: Verify form of variable names.
    Map map = (_function_level == null ? _top_level : _function_level);
    return new Initialization(new Variable.create(map, first), constant);
  }

  Variable getVariable() {
    String variable = _lexer.getNext;
    Variable v = _function_level == null ? null : _function_level[variable];
    if (v == null) v = _top_level[variable];
    if (v == null) _error("Unknown variable: $variable");
    return v;
  }

  Assignment parseAssignment() {
    Expression expression = parseExpression(0);
    _lexer.accept("into");
    return new Assignment(getVariable(), expression);
  }

  Assignment parseIncrement() {
    Variable v = getVariable();
    _lexer.accept("up");
    return new Assignment(v, new Binary(v, "plus", new IntegerConstant(1)));
  }

  Assignment parseDecrement() {
    Variable v = getVariable();
    _lexer.accept("down");
    return new Assignment(v, new Expression(v, _lexer.keywords["minus"], new IntegerConstant(1)));
  }

  Statement parseConditional() {
    String keyword = _lexer.getNext;
    Expression test = parseExpression(0);
    ConditionStatement cond = new ConditionStatement(keyword, test);
    while (_lexer.current != "\n" && _lexer.current != null) {
      Declaration s = parseDeclaration();
      if (s is RockstarFunction) _error("Can't define a function inside a block");
      cond.statements.add(s);
    }
    _lexer.accept("\n");
    return cond;
  }

  Statement parseSay() {
    var f = new FunctionInvocation(_say);
    f.arguments.add(parseExpression(0));
    return f;
  }

  Statement parseListen() {
    _lexer.accept("to");
    return new Listen(getVariable());
  }

  Statement parseReturn() {
    return new Return(parseExpression(0));
  }

  RockstarFunction parseFunctionDeclaration(String name) {
    if (_functions.containsKey(name)) _error("Two functions called $name");
    if (_function_level != null) _error("Function $name is nested inside another function");
    Map<String, Variable> locals = _function_level = new Map<String, Variable>();
    while (_lexer.current != "\n" && _lexer.current != null) {
      Variable v = new Variable.create(locals, _lexer.getNext);
      if (!_lexer.accept("and")) break;
    }
    UserFunction f = new UserFunction(name, locals);
    while (_lexer.current != "\n" && _lexer.current != null) {
      Declaration s = parseDeclaration();
      if (s is RockstarFunction) _error("Can't define a function inside a block");
      f.statements.add(s);
    }
    _function_level = null;
    return f;
  }

  FunctionInvocation parseFunctionCall() {
    String name = _lexer.getNext;
    _lexer.expect("taking");
    RockstarFunction f = _functions[name];
    var inv = new FunctionInvocation(f);
    for (int i = 0; i < f.arity; i++) {
      inv.arguments.add(parseExpression(3));
      //if (i + 1 < f.arity) _lexer.expect(",");   // comma
    }
    return inv;
  }

  Expression parseExpression(int prescedence) {
    if (_functions.containsKey(_lexer.current)) {
      Expression part1 = parseFunctionCall();
      return parseRestOfExpression(part1, prescedence);
    }
    Expression current = expressionFromFirst(_lexer.getNext);
    return parseRestOfExpression(current, prescedence);
  }

  Expression expressionFromFirst(part1) {
    if (part1 is int) return new IntegerConstant(part1);
    if (part1 is double) return new FloatConstant(part1);
    if (oddballs.containsKey(part1)) return new Oddball(part1);
    if (part1 == '"') {
      // Literal string expression.
      if (!(_lexer.current is String)) _error("Internal error");
      return new StringConstant(_lexer.currentString);
    }
    return new Variable(_function_level, _top_level, part1);
  }

  Expression parseRestOfExpression(Expression current, int prescedence) {
    while (true) {
      var operator = _lexer.current;
      int next_prescedence = _prescedence_table[operator];
      if (next_prescedence == null) return current;
      if (next_prescedence == prescedence) {
        current = new Binary(current, _lexer.getNext, parseExpression(next_prescedence));
      } else if (next_prescedence > prescedence) {
        current = parseRestOfExpression(current, next_prescedence);
      } else {
        return current;
      }
    }
  }
}

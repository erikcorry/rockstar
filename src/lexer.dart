import "package:charcode/ascii.dart";

class Lexer {
  Lexer(this._program) {
    _initialize_first_words();
    get();
  }
  String _program;
  var current;
  String currentString;
  int _pos = 0;
  void accept(String something) {
    assert(current == something);
    get();
  }

  String get getNext {
    String answer = current;
    get();
    return answer;
  }

  bool _isWhiteSpace(int c) {
    if ($a <= c && c <= $z) return false;
    if ($A <= c && c <= $Z) return false;
    if (c == $single_quote) return false;
    if ($0 <= c && c <= $9) return false;
    if (c == $double_quote) return false;
    return true;
  }

  int _codeUnit(int index) {
    return _program.codeUnitAt(index);
  }

  void get() {
    bool whitespace = true;
    while (whitespace && _pos < _program.length) {
      int c = _codeUnit(_pos);
      if (c == $open_parenthesis) {
        _pos++;
        // Comment.
        while (_pos < _program.length) {
          c = _codeUnit(_pos);
          _pos++;
          if (c == $close_parenthesis) break;
        }
      } else if (!_isWhiteSpace(c)) {
        whitespace = false;
      } else {
        _pos++;
      }
    }
    if (_pos == _program.length) {
      current = null;
      return;
    }
    if (current == "says") {
      getPoeticString();
      return;
    }
    int c = _codeUnit(_pos);
    if (c == $double_quote) {
      getString();
      return;
    } else if (c >= $A && c <= $Z) {
      getToken(true);
      // "Baby" doesn't change the meaning of a rock song, so get the next
      // token.
      if (current == "baby") get();
    } else if (c >= $0 && c <= $9) {
      getNumber();
    } else {
      getToken(false);
      // "Baby" doesn't change the meaning of a rock song, so get the next
      // token.
      if (current == "baby") get();
    }
  }

  void getPoeticString() {
    int start = _pos;
    while (true) {
      if (_pos == _program.length || _codeUnit(_pos) == $lf) {
        currentString = _program.substring(start, _pos);
        current = '"';
        return;
      }
      _pos++;
    }
  }

  void getNumber() {
    int r = 0;
    int c = _codeUnit(_pos++);
    int divisor = 0;
    while (true) {
      r *= 10;
      r += c - $0;
      divisor *= 10;
      if (_pos == _program.length) {
        current = r / (divisor == 0 ? 1 : divisor);
        return;
      }
      bool again = true;
      while (again) {
        c = _codeUnit(_pos);
        if (c < $0 || c > $9) {
          if (c != $dot || divisor != 0) {
            current = r / (divisor == 0 ? 1 : divisor);
            return;
          }
          divisor = 1;
        } else {
          again = false;
        }
        _pos++;
      }
    }
  }

  var possessives = {
    "my": "my",
    "My": "my",
    "the": "the",
    "The": "the",
    "your": "your",
    "Your": "your",
    "a": "a",
    "A": "a",
    "an": "an",
    "An": "an"
  };

  var _keywords = {
    "baby": "baby",
    "Baby": "baby",
    "takes": "takes",
    "and": "and",
    "give": "give",
    "Give": "give",
    "back": "back",
    "Back": "back",
    "taking": "taking",
    "If": "if",
    "if": "if",
    "Else": "else",
    "else": "else",
    "While": "while",
    "while": "while",
    "Until": "until",
    "until": "until",
    "Break": "break",
    "break": "break",
    "Continue": "continue",
    "continue": "continue",
    "Knock": "knock",
    "knock": "knock",
    "down": "down",
    "Build": "build",
    "build": "build",
    "up": "up",
    "true": "true",
    "right": "true",
    "yes": "true",
    "ok": "true",
    "OK": "true",
    "false": "false",
    "wrong": "false",
    "no": "false",
    "lies": "false",
    "mysterious": "mysterious",
    "null": "null",
    "nothing": "null",
    "nowhere": "null",
    "nobody": "null",
    "Shout": "say",
    "shout": "say",
    "whisper": "say",
    "Whisper": "say",
    "say": "say",
    "Say": "say",
    "says": "says",
    "plus": "plus",
    "with": "plus",
    "minus": "minus",
    "without": "minus",
    "times": "times",
    "of": "times",
    "over": "over",
    "by": "over",
    "put": "put",
    "Put": "put",
    "into": "into",
    "is": "is",
    "was": "is",
    "were": "is",
    "higher than": "greater than",
    "greater than": "greater than",
    "bigger than": "greater than",
    "stronger than": "greater than",
    "lower than": "less than",
    "less than": "less than",
    "smaller than": "less than",
    "weaker than": "less than",
    "as high as": "as great as",
    "as great as": "as great as",
    "as big as": "as great as",
    "as strong as": "as great as",
    "as low as": "as low as",
    "as little as": "as low as",
    "as small as": "as low as",
    "as weak as": "as low as",
    "is not": "is not",
    "ain't": "is not",
    "listen": "listen",
    "Listen": "listen",
    "listen to": "listen to",
    "Listen to": "listen to",
    "it": "it",
    "he": "it",
    "she": "it",
    "him": "it",
    "her": "it",
    "them": "it",
  };

  var _first_words = {};
  var _composite_keywords = {};

  void _initialize_first_words() {
    for (String keyword in _keywords.keys) {
      int i = keyword.indexOf(" ");
      if (i != -1) {
        String first = keyword.substring(0, i);
        _first_words[first] = first;
        _composite_keywords[keyword] = 1;
      }
    }
  }

  bool _nextTokenStartsWithCapital() {
    int p = _pos;
    while (p < _program.length) {
      int c = _codeUnit(p);
      if (_isWhiteSpace(c)) {
        p++;
        continue;
      }
      return $A <= c && c <= $Z;
    }
    return false;
  }

  void getToken(bool proper) {
    int start = _pos;
    var chars = null;
    while (_pos < _program.length) {
      int c = _codeUnit(_pos);
      if (_isWhiteSpace(c)) {
        String so_far = _program.substring(start, _pos);
        String possessive = possessives[so_far];
        if (possessive != null) {
          get();
          if (current == '"') _error("Literal string after $possessive");
          if (current is int) _error("Integer after $possessive");
          if (_keywords.containsKey(current)) _error("Keyword after $possessive");
          int c = current.codeUnitAt(0);
          if ($A <= c && c <= $Z) _error("Proper name after $possessive");
          current = "$possessive $current";
          return;
        }
        if (_first_words.containsKey(so_far)) {
          for (String composite in _composite_keywords.keys) {
            if (composite.matchAsPrefix(_program, start) != null &&
                (_program.length == start + composite.length || _isWhiteSpace(_codeUnit(start + composite.length)))) {
              current = _keywords[composite];
              _pos = start + composite.length;
              return;
            }
          }
        }
        if (_keywords.containsKey(so_far)) {
          current = _keywords[so_far];
          return;
        }
        if (!proper || !_nextTokenStartsWithCapital()) {
          if (chars == null) {
            current = so_far;
          } else {
            current = new String.fromCharCodes(chars);
          }
          return;
        } else {
          chars = _makeCharArray(start, _pos, chars);
          chars.add($space);
          while (_isWhiteSpace(_codeUnit(_pos))) _pos++;
          continue;
        }
      }
      if (chars != null) chars.add(c);
      _pos++;
    }
    if (chars == null) {
      current = _program.substring(start, _pos);
    } else {
      current = new String.fromCharCodes(chars);
    }
    if (_keywords.containsKey(current)) current = _keywords[current];
  }

  _makeCharArray(int from, int to, chars) {
    if (chars != null) return chars;
    chars = [];
    for (int i = 0; i < to - from; i++) {
      chars.add(_codeUnit(from + i));
    }
    return chars;
  }

  void getString() {
    _pos++;
    int start = _pos;
    var chars = null;
    while (_pos < _program.length) {
      int c = _codeUnit(_pos);
      if (c == $backslash) {
        _pos += 2;
        if (_pos > _program.length) _error("File ends in backslash");
        chars = _makeCharArray(start, _pos, chars);
        c = _codeUnit(_pos - 1);
        if (c == $n) chars.add($lf);
        else if (c == $r) chars.add($cr);
        else if (c == $t) chars.add($ht);
        else if (c == $backslash) chars.add($backslash);
        else if (c == $double_quote) chars.add($double_quote);
        else if (c == $0) chars.add(0);
        else _error("Unknown escape in string literal");
        continue;
      }
      if (c == $double_quote) {
        if (chars == null) {
          currentString = _program.substring(start, _pos);
        } else {
          currentString = new String.fromCharCodes(chars);
        }
        _pos++;
        current = '"';
        return;
      }
      if (chars != null) chars.add(c);
      _pos++;
    }
    _pos = start;
    _error("Unterminated string");
  }

  void _error(String message) {
    String str = "Error at byte postion $_pos: $message";
    print(str);
    throw str;
  }
}

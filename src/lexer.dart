import "package:charcode/ascii.dart";

const NOT_INITIALIZER = -1;
const START_OF_LINE = 0;
const AFTER_VARIABLE_NAME = 1;
const AFTER_SAYS = 2;
const AFTER_IS = 3;

class Lexer {
  Lexer(this._program) {
    _initialize_first_words();
    get();
  }
  String _program;
  var current;
  String currentString;
  int _pos = 0;
  int line_no = 1;

  int _poetic_state = START_OF_LINE;

  bool accept(something) {
    if (current == something) {
      get();
      return true;
    }
    return false;
  }

  void expect(something) {
    if (current != something) error("Expected '$something', found '$current'");
    getNext;
  }

  String get getNext {
    String answer = current;
    get();
    return answer;
  }

  bool _isIdentifierChar(int c) {
    if ($a <= c && c <= $z) return true;
    if ($A <= c && c <= $Z) return true;
    if (c == $single_quote) return true;
    return false;
  }

  bool _isWhiteSpace(int c) {
    //if (c == $comma) return false;
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
    bool seen_newline = false;
    bool seen_blank_line = false;
    while (whitespace && _pos < _program.length) {
      int c = _codeUnit(_pos);
      // Ignore commas at the end of a line.
      bool ignorable_comma = c == $comma;
      if (_pos + 1 < _program.length && _codeUnit(_pos + 1) != $lf) ignorable_comma = false;
      if (c == $lf) {
        _poetic_state = START_OF_LINE;
        if (seen_newline) seen_blank_line = true;
        seen_newline = true;
      }
      if (c == $open_parenthesis) {
        _pos++;
        // Comment.
        while (_pos < _program.length) {
          c = _codeUnit(_pos);
          _pos++;
          if (c == $close_parenthesis) break;
        }
      } else if (!_isWhiteSpace(c) && !ignorable_comma) {
        whitespace = false;
      } else {
        if (c == $lf) line_no++;
        _pos++;
      }
    }
    if (seen_blank_line) {
      current = "\n";  // Blank line.
      return;
    }
    if (_pos == _program.length) {
      current = null;
      return;
    }
    if (_poetic_state == AFTER_SAYS) {
      _getPoeticString();
      _poetic_state = NOT_INITIALIZER;
      return;
    }
    int c = _codeUnit(_pos);
    if (c == $double_quote) {
      _poetic_state = NOT_INITIALIZER;
      getString();
      return;
    //} else if (c == $comma) {
      //_poetic_state = NOT_INITIALIZER;
      //current = ",";
      //_pos++;
      //return;
    } else if (c >= $A && c <= $Z) {
      getToken(true);
      // "Baby" doesn't change the meaning of a rock song, so get the next
      // token.
      if (current == "baby") get();
      _updatePoeticState();
    } else if (c >= $0 && c <= $9) {
      getNumber();
      _poetic_state = NOT_INITIALIZER;
    } else {
      getToken(false);
      // "Baby" doesn't change the meaning of a rock song, so get the next
      // token.
      if (current == "baby") get();
      _updatePoeticState();
    }
  }

  void _updatePoeticState() {
    if (_poetic_state == START_OF_LINE) _poetic_state = AFTER_VARIABLE_NAME;
    else if (_poetic_state == AFTER_VARIABLE_NAME && current == "is") _poetic_state = AFTER_IS;
    else if (_poetic_state == AFTER_VARIABLE_NAME && current == "says") _poetic_state = AFTER_SAYS;
    else _poetic_state = NOT_INITIALIZER;
  }

  void _getPoeticString() {
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
        current = divisor == 0 ? r : r / divisor;
        return;
      }
      bool again = true;
      while (again) {
        c = _codeUnit(_pos);
        if (c < $0 || c > $9) {
          if (c != $dot) {
            current = divisor == 0 ? r : r / divisor;
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

  bool _isPoeticAlpha(int c) => ($a <= c && c <= $z) || ($A <= c && c <= $Z);

  _getWordLength() {
    int c = 0;
    while (_pos < _program.length && _isPoeticAlpha(_codeUnit(_pos))) {
      _pos++;
      c++;
    }
    return c % 10;
  }

  void _getPoeticNumber() {
    int r = 0;
    int c = _getWordLength();
    int divisor = 0;
    while (true) {
      r *= 10;
      r += c;
      divisor *= 10;
      if (_pos == _program.length || _codeUnit(_pos) == $lf) {
        current = divisor == 0 ? r : r / divisor;
        return;
      }
      bool again = true;
      while (again) {
        while (_pos != _program.length && _codeUnit(_pos) != $lf && (divisor != 0 || _codeUnit(_pos) != $dot) && _codeUnit(_pos) != $open_parenthesis && !_isPoeticAlpha(_codeUnit(_pos))) {
          _pos++;
        }
        if (_pos == _program.length || _codeUnit(_pos) == $lf) {
          current = divisor == 0 ? r : r / divisor;
          return;
        } else if (_codeUnit(_pos) == $open_parenthesis) {
          _pos++;
          while (_pos != _program.length && _codeUnit(_pos) != $close_parenthesis) _pos++;
        } else if (divisor == 0 && _codeUnit(_pos) == $dot) {
          divisor = 1;
        } else {
          c = _getWordLength();
          again = false;
        }
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
    "give back": "give back",
    "Give back": "give back",
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
    "Take it to the top": "continue",
    "take it to the top": "continue",
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
    "is higher than": "is greater than",
    "is greater than": "is greater than",
    "is bigger than": "is greater than",
    "is stronger than": "is greater than",
    "is lower than": "is less than",
    "is less than": "is less than",
    "is smaller than": "is less than",
    "is weaker than": "is less than",
    "is as high as": "is as great as",
    "is as great as": "is as great as",
    "is as big as": "is as great as",
    "is as strong as": "is as great as",
    "is as low as": "is as low as",
    "is as little as": "is as low as",
    "is as small as": "is as low as",
    "is as weak as": "is as low as",
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
      if (_isWhiteSpace(c) && c != $lf) {
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
      if (!_isIdentifierChar(c)) {
        String so_far = _program.substring(start, _pos);
        String possessive = possessives[so_far];
        // After "is" or one of its aliases we don't want to identify
        // possessives (which are not real keywords).  This allows "Tommy was a
        // lovestruck ladykiller" to work as a poetic numeric literal, and not
        // a variable called "a lovestruck".
        if (_poetic_state != AFTER_IS && possessive != null) {
          // TODO: This is pretty ugly!  The problem is we are reusing "get()"
          // to get the second part of a posessive variable, which causes all
          // sorts of trouble.  Make a specialized routine instead.
          int temp = _poetic_state;
          get();
          _poetic_state = temp;
          if (current == '"') error("Literal string after $possessive");
          if (current is num) error("Integer after $possessive");
          if (_keywords.containsKey(current)) error("Keyword after $possessive");
          int c = current.codeUnitAt(0);
          if ($A <= c && c <= $Z) error("Proper name after $possessive");
          current = "$possessive $current";
          return;
        }
        if (_first_words.containsKey(so_far)) {
          for (String composite in _composite_keywords.keys) {
            if (composite.matchAsPrefix(_program, start) != null &&
                (_program.length == start + composite.length || !_isIdentifierChar(_codeUnit(start + composite.length)))) {
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
        if (_poetic_state == AFTER_IS) {
          _pos = start;
          _getPoeticNumber();
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
        if (_pos > _program.length) error("File ends in backslash");
        chars = _makeCharArray(start, _pos, chars);
        c = _codeUnit(_pos - 1);
        if (c == $n) chars.add($lf);
        else if (c == $r) chars.add($cr);
        else if (c == $t) chars.add($ht);
        else if (c == $backslash) chars.add($backslash);
        else if (c == $double_quote) chars.add($double_quote);
        else if (c == $0) chars.add(0);
        else error("Unknown escape in string literal");
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
    error("Unterminated string");
  }

  void error(String message) {
    String str = "Error on line $line_no at byte postion $_pos: $message";
    throw str;
  }
}

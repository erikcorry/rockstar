import "lexer.dart";

main() {
  demo('Shout "Hello, World!"', ["say", '"', "Hello, World!"]);
  demo('Build my world up', ["build", 'my world', "up"]);
  demo('Build my world up baby', ["build", 'my world', "up"]);
  demo('Baby build my world up', ["build", 'my world', "up"]);
  demo('Build my world up', ["build", 'my world', "up"]);
  demo('Build my\n   world up', ["build", 'my world', "up"]);
  demo('Tommy The Pinball Wizard says I\'m the best\n', ["Tommy The Pinball Wizard", 'says', '"', "I'm the best"]);
  demo("I ain't talkin' 'bout love", ["I", "is not", "talkin'", "'bout", "love"]);

  demo("Put 123 into X", ["put", 123, "into", "X"]);
  demo('Put "Hello World" into the message', ["put", '"', "Hello World", "into", "the message"]);

  demo("Build my world up", ["build", "my world", "up"]);
  demo("Knock the walls down", ["knock", "the walls", "down"]);

  demo("Put the whole of my heart into your hands", ["put", "the whole", "times", "my heart", "into", "your hands"]);
  demo("My world is nothing without your love", ["my world", "is", "null", "minus", "your love"]);
  demo("If the tears of a child is nothing", ["if", "the tears", "times", "a child", "is", "null"]);
  demo("My love by your eyes", ["my love", "over", "your eyes"]);

  demo("My heart is true", ["my heart", "is", "true"]);
  demo("Tommy is nobody", ["Tommy", "is", "null"]);

  demo("Billy says hello world!\n", ["Billy", "says", '"', "hello world!"]);
  demo("The world says hello back\n", ["the world", "says", '"', "hello back"]);

  demo("If Tommy is nobody", ["if", "Tommy", "is", "null"]);

  demo("Listen to your heart", ["listen to", "your heart"]);
  demo("Say Tommy", ["say", "Tommy"]);

  demo("Tommy was 16", ["Tommy", "is", 16]);
  demo("While Tommy ain't nothing", ["while", "Tommy", "is not", "null"]);
  demo("Knock Tommy down", ["knock", "Tommy", "down"]);

  demo("Shout it", ["say", "it"]);
  demo("Knock it down", ["knock", "it", "down"]);

  demo("Multiply takes X and Y", ["Multiply", "takes", "X", "and", "Y"]);
  demo("Search takes Needle and Haystack", ["Search", "takes", "Needle", "and", "Haystack"]);
}

demo(String program, List tokens) {
  var lex = new Lexer(program);
  for (int i = 0; i < tokens.length; i++) {
    if (lex.current != tokens[i]) {
      throw "Expected '${tokens[i]}', got '${lex.current}'";
    }
    String token = lex.getNext;
    if (token == '"') {
      i++;
      if (lex.currentString != tokens[i]) {
        throw "Expected '${tokens[i]}', got '${lex.currentString}'";
      }
    }
  }
  if (lex.current != null) throw "Unparsed junk at end";
  print("Lexed '$program' to $tokens");
}

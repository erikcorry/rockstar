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
  demo("Put 3.1415 into X", ["put", 3.1415, "into", "X"]);
  demo("Put 3. into X", ["put", 3, "into", "X"]);
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

  demo("Tommy was a lovestruck ladykiller", ["Tommy", "is", 100]);
  demo("Sweet Lucy was a dancer", ["Sweet Lucy", "is", 16]);
  demo("A killer is on the loose", ["a killer", "is", 235]);
  demo("My dreams were ice. A life unfulfilled; wakin' everybody up, taking booze and pills",
       ["my dreams", "is", 3.1415926535]);

  demo("If Tommy is nobody", ["if", "Tommy", "is", "null"]);

  demo("Listen to your heart", ["listen to", "your heart"]);
  demo("Say Tommy", ["say", "Tommy"]);

  demo("Tommy was a dancer", ["Tommy", "is", 16]);
  demo("While Tommy ain't nothing", ["while", "Tommy", "is not", "null"]);
  demo("Knock Tommy down", ["knock", "Tommy", "down"]);

  demo("Shout it", ["say", "it"]);
  demo("Knock it down", ["knock", "it", "down"]);

  demo("Multiply takes X and Y", ["Multiply", "takes", "X", "and", "Y"]);
  demo("Search takes Needle and Haystack", ["Search", "takes", "Needle", "and", "Haystack"]);

  demo("Tommy was a lean mean wrecking machine.   (Initializes Tommy with 14487)", ["Tommy", "is", 14487]);

  demo("Continue\n    (blank like ending 'If' Block)\nIf Modulus taking Counter and Fizz is 0",
       ["continue", "\n", "if", "Modulus", "taking", "Counter", "and", "Fizz", "is", 0]);

  demo("I love you (and that's the truth), but I'm gonna leave you", ["I", "love", "you", "but", "I'm", "gonna", "leave", "you"]);

  demo("Line\nline", ["Line", "line"]);
  demo("Line\n\nline", ["Line", "\n", "line"]);
  demo("Line\n   \n  line", ["Line", "\n", "line"]);
  demo("Line\n   (comment on blank line)\n  line", ["Line", "\n", "line"]);
  // Multiple blank lines lex as one blank line.
  demo("Line\n   (comment on blank line)\n\n\n  line", ["Line", "\n", "line"]);

  // Ideomatic Fizzbuzz:
  demo("""
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

Whisper my world
""",
  [
    "Midnight", "takes", "your heart", "and", "your soul",
    "while", "your heart", "is as great as", "your soul",
    "put", "your heart", "minus", "your soul", "into", "your heart",
    "\n",

    "give back", "your heart",
    "\n",

    "Desire", "is", 100,
    "my world", "is", "null",
    "Fire", "is", 3,
    "Hate", "is", 5,
    "until", "my world", "is", "Desire",
    "build", "my world", "up",
    "if", "Midnight", "taking", "my world", "Fire", "is", "null", "and", "Midnight", "taking", "my world", "Hate", "is", "null",
    "say", '"', "FizzBuzz!",
    "continue",
    "\n",

    "if", "Midnight", "taking", "my world", "Fire", "is", "null",
    "say", '"', "Fizz!",
    "continue",
    "\n",

    "if", "Midnight", "taking", "my world", "Hate", "is", "null",
    "say", '"', "Buzz!",
    "continue",
    "\n",

    "say", "my world"
  ]);
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

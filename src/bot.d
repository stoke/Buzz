import std.string, std.conv, std.stream, std.stdio;
import std.socket, std.socketstream, std.conv;
import IRCUtils, IRCBot, opt;



bool includes(T)(T[] haystack, T needle) {
  foreach (elem; haystack) {
    if (elem == needle) return true;
  }

  return false;
}

void usage() {
  writeln("bot -s <server> -p <port> -c <chan>");
  exit();
}

void realMain(string[] args) {
  auto argv = optParse(args);

  if (!includes(argv.keys, "s") || !includes(argv.keys, "p") || !includes(argv.keys, "c"))
    usage();

  IRCBot bot = new IRCBot(argv["s"], parse!ushort(argv["p"]));

  // Just an example
  bot.addMessageListener(function int(string nick, string text, IRCUtils irc) {
    string[] args = split(text);
    
    if (args[0] == "!nick")
      irc.changeNick(args[1]);

    if (args[0] == "!join")
      irc.chanJoin(args[1]);

    return 0;
  });
}


// Workaround to provide an exit function
int main(string[] args) { 
  try { 
    realMain(args); 
  } catch (ExitException e) { 
    return 0; 
  }

  return 0;
}

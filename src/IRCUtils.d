import std.string, std.conv, std.stream, std.stdio, std.array;
import std.socket, std.socketstream;

class ExitException : Exception
{
    this(string message)
    {
        super(message);
    }
}

void exit() { throw new ExitException("foo"); }

class IRCUtils {
  Stream ss;
  Socket sock;

  this(Stream str, Socket s) {
    this.ss = str;
    this.sock = s;
  }

  string[] parseLine(string line) {
    string cmd, prefix;
    string[] args;

    if (line[0] == ':') {
        auto s = split(line);

        prefix = s[0].idup;
        cmd = s[1].idup;
        args = cast(string[]) s[2..$].dup;
    } else {
      auto s = split(line);

      prefix = "";
      cmd = s[0].idup;
      args = cast(string[]) s[1..$].dup;
    }

    return cast(string[]) join([[prefix, cmd], args]).dup;
  }

  void sendMessage(string text, string chan) {
    ss.writeString("PRIVMSG "~ chan ~" :"~ text ~"\r\n");
  }

  void changeNick(string nick) {
    ss.writeString("NICK "~ nick ~"\r\n");
  }

  void kick(string nick) {
    ss.writeString("KICK "~ nick ~"\r\n");
  }

  void chanJoin(string chan) {
    ss.writeString("JOIN "~ chan ~"\r\n");
  }

  string[] who(string chan) {
    ss.writeString("NAMES "~ chan ~"\r\n");

    auto parsed = parseLine(cast(string) ss.readLine());

    auto nicks = cast(char[][]) parsed[5..$].dup;
    nicks[0] = nicks[0][1..$];

    return cast(string[]) nicks.dup;
  }
}
import std.string, std.conv, std.stream, std.stdio;
import std.socket, std.socketstream;
import core.thread;
import IRCUtils;


class IRCBot : IRCUtils {
  Socket sock;
  Stream ss;
  int function(string, string, IRCUtils)[] middlewares;

  this(string domain, ushort port) {
    Thread router = new Thread(&this.startRouting);
    
    this.sock = new TcpSocket(new InternetAddress(domain, port));
    this.ss = new SocketStream(this.sock);
    ss.writeString("NICK lolbot\r\n"
                   "USER lolbot lolbot "~ domain ~" :lolbot\r\n");

    super(ss, sock);

    router.start();
  }

  void addMessageListener(int function(string, string, IRCUtils) fun) {
    middlewares ~= fun;
  }

  void pong(string prefix, string cmd, string[] args) {
    ss.writeString("PONG "~ args[0] ~"\r\n");
  }

  void parsePRIVMSG(string prefix, string cmd, string[] args) {
    int ret;
    string chan = args[0].idup, nick = prefix[1..indexOf(prefix, '!')];
    string message = cast(string) join(split(args[1][1..$]).dup ~ args[2..$].dup, " ");


    foreach (elem; middlewares) {
      ret = elem(nick, message, new IRCUtils(ss, sock));

      if (ret < 0) {
        ss.writeString("QUIT :bb\r\n");
        sock.close();
        exit();
      }

    }
  }

  void startRouting() {
    string cmd, prefix;
    string[] args;

    while (true) {
      auto line = ss.readLine();
     

      if (!line.length)
        sock.close();

      auto parsed = parseLine(cast(string) line);

      prefix = parsed[0].idup;
      cmd = parsed[1].idup;
      args = cast(string[]) parsed[2..$].dup;

      switch (cmd) {
        case "PING":
          pong(prefix, cmd, args);
          break;

        case "PRIVMSG":
          parsePRIVMSG(prefix, cmd, args);
          break;

        default:
          writefln("%s %s", cmd, args[0]);
          break;
      }
    }
  }
}
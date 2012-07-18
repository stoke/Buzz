// Optimist-like (https://github.com/substack/node-optimist/) argument parser

string[string] optParse(string[] argv) {
  string[string] args;
  int startindex;

  for (auto index = 0; index < argv.length; index++) {
    if (argv[index][0] == '-') {
      startindex = (argv[index][1] == '-') ? 2 : 1; 

      args[argv[index][startindex..$]] = (index == argv.length-1) ? "" : argv[++index];
    }
  }

  return args;
}
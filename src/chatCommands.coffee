commands = [
  require("./commands/giphy").default,
  require("./commands/emoticonDirectory").default,
  require("./commands/refresh").default,
  require("./commands/megaKeith").default
]

export default (command, args) ->
  for commandProcessor in commands
    commandProcessor(command, args)

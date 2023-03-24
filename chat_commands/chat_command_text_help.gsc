#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "help", "text", array("Type " + GetDvar("cc_prefix") + "commands to get a list of commands", "Type " + GetDvar("cc_prefix") + "help followed by a command name to see how to use it"), 1);
}
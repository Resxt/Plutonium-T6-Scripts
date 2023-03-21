/*
==========================================================================
|                            Game: Plutonium T6                          |
|               Description : Display text and run GSC code              | 
|                      by typing commands in the chat                    |
|                             Author: Resxt                              |
==========================================================================
|  https://github.com/Resxt/Plutonium-T6-Scripts/tree/main/chat_commands |
==========================================================================
*/



/* Init section */

Main() 
{
    InitChatCommands();
}

InitChatCommands()
{
    InitChatCommandsDvars();

    level.chat_commands = []; // don't touch
    level.chat_commands["ports"] = array("4976", "4977"); // an array of the ports of all your servers you want to have the script running on. This is useful to easily pass this array as first arg of CreateCommand to have the command on all your servers
    level.chat_commands["no_commands_message"] = array("^1No commands found", "You either ^1didn't add any chat_command file ^7to add a new command ^1or ^7there are ^1no command configured on this port", "chat_commands.gsc is ^1just the base system. ^7It doesn't provide any command on its own", "Also ^1make sure the ports are configured properly ^7in the CreateCommand function of your command file(s)"); // the lines to print in the chat when the server doesn't have any command added
    level.chat_commands["no_commands_wait"] = 6; // time to wait between each line in <level.chat_commands["no_commands_message"]> when printing that specific message in the chat

    level thread OnPlayerConnect();
    level thread ChatListener();
}

InitChatCommandsDvars()
{
    SetDvarIfNotInitialized("cc_debug", 0);
    SetDvarIfNotInitialized("cc_prefix", "!");
    
    SetDvarIfNotInitialized("cc_permission_enabled", 0);
    SetDvarIfNotInitialized("cc_permission_mode", "name");
    SetDvarIfNotInitialized("cc_permission_default", 1);
    SetDvarIfNotInitialized("cc_permission_max", 4);

    for (i = 0; i <= GetDvarInt("cc_permission_max"); i++)
    {
        SetDvarIfNotInitialized("cc_permission_" + i, "");
    }
}



/* Commands section */

/*
<serverPorts> the ports of the servers this command will be created for
<commandName> the name of the command, this is what players will type in the chat
<commandType> the type of the command: <text> is for arrays of text to display text in the player's chat and <function> is to execute a function
<commandValue> when <commandType> is "text" this is an array of lines to print in the chat. When <commandType> is "function" this is a function pointer (a reference to a function)
<commandMinimumPermission> (optional, if no value is provided then anyone who's permission level is default or above can run the command) the minimum permission level required to run this command. For example if this is set to 3 then any user with permission level 3 or 4 will be able to run this command
<commandHelp> (optional) an array of the lines to print when typing the help command in the chat followed by a command name. You can also pass an array of one preset string to have it auto generated, for example: ["default_help_one_player"] 
*/
CreateCommand(serverPorts, commandName, commandType, commandValue, commandMinimumPermission, commandHelp)
{
    foreach (serverPort in serverPorts)
    {
        level.commands[serverPort][commandName]["type"] = commandType;

        if (IsDefined(commandHelp))
        {
            commandHelpMessage = commandHelp;
            commandHelpString = commandHelp[0];
            
            if (commandHelpString == "default_help_one_player")
            {
                commandHelpMessage = array("Example: " + GetDvar("cc_prefix") + commandName + " me", "Example: " + GetDvar("cc_prefix") + commandName + " Resxt");
            }
            else if (commandHelpString == "default_help_two_players")
            {
                commandHelpMessage = array("Example: " + GetDvar("cc_prefix") + commandName + " me Resxt", "Example: " + GetDvar("cc_prefix") + commandName + " Resxt me", "Example: " + GetDvar("cc_prefix") + commandName + " Resxt Eldor");
            }

            level.commands[serverPort][commandName]["help"] = commandHelpMessage;
        }
    
        if (commandType == "text")
        {
            level.commands[serverPort][commandName]["text"] = commandValue;
        }
        else if (commandType == "function")
        {
            level.commands[serverPort][commandName]["function"] = commandValue;
        }

        if (IsDefined(commandMinimumPermission))
        {
            level.commands[serverPort][commandName]["permission"] = commandMinimumPermission;
        }
        else
        {
            level.commands[serverPort][commandName]["permission"] = GetDvarInt("cc_permission_default");
        }
    }
}



/* Chat section */

ChatListener()
{
    while (true) 
    {
        level waittill("say", message, player);

        if (message[0] != GetDvar("cc_prefix")) // For some reason checking for the buggy character doesn't work so we start at the second character if the first isn't the command prefix
        {
            message = GetSubStr(message, 1); // Remove the random/buggy character at index 0, get the real message
        }

        if (message[0] != GetDvar("cc_prefix")) // If the message doesn't start with the command prefix
        {
            continue; // stop
        }

        if (PermissionIsEnabled() && player GetPlayerPermissionLevel() == 0)
        {
            player thread TellPlayer(InsufficientPermissionError(0), 1);
            continue; // stop
        }

        commandArray = StrTok(message, " "); // Separate the command by space character. Example: ["!map", "mp_dome"]
        command = commandArray[0]; // The command as text. Example: !map
        args = []; // The arguments passed to the command. Example: ["mp_dome"]
        arg = "";

        for (i = 1; i < commandArray.size; i++)
        {
            checkedArg = commandArray[i];

            if (checkedArg[0] != "'" && arg == "")
            {
                args = AddElementToArray(args, checkedArg);
            }
            else if (checkedArg[0] == "'")
            {
                arg = StrTok(checkedArg, "'")[0] + " ";
            }
            else if (checkedArg[checkedArg.size - 1] == "'")
            {
                args = AddElementToArray(args, (arg + StrTok(checkedArg, "'")[0]));
                arg = "";
            }
            else
            {
                arg += (checkedArg + " ");
            }
        }

        if (IsDefined(level.commands[GetDvar("net_port")]))
        {
            if (command == GetDvar("cc_prefix") + "commands") // commands command
            {
                if (GetDvarInt("cc_permission_enabled"))
                {
                    playerCommands = [];

                    foreach (commandName in GetArrayKeys(level.commands[GetDvar("net_port")]))
                    {
                        if (PlayerHasSufficientPermissions(player, level.commands[GetDvar("net_port")][commandName]["permission"]))
                        {
                            playerCommands = AddElementToArray(playerCommands, commandName);
                        }
                    }

                    player thread TellPlayer(playerCommands, 2, true);
                }
                else
                {
                    player thread TellPlayer(GetArrayKeys(level.commands[GetDvar("net_port")]), 2, true);
                }
            }
            else
            {
                // help command
                if (command == GetDvar("cc_prefix") + "help" && !IsDefined(level.commands[GetDvar("net_port")]["help"]) || command == GetDvar("cc_prefix") + "help" && IsDefined(level.commands[GetDvar("net_port")]["help"]) && args.size >= 1)
                {
                    if (args.size < 1)
                    {
                        player thread TellPlayer(NotEnoughArgsError(1), 1.5);
                    }
                    else
                    {
                        commandValue = level.commands[GetDvar("net_port")][args[0]];

                        if (IsDefined(commandValue))
                        {
                            if (!PermissionIsEnabled() || PlayerHasSufficientPermissions(player, commandValue["permission"]))
                            {
                                commandHelp = commandValue["help"];

                                if (IsDefined(commandHelp))
                                {
                                    player thread TellPlayer(commandHelp, 1.5);
                                }
                                else
                                {
                                    player thread TellPlayer(CommandHelpDoesNotExistError(args[0]), 1);
                                }
                            }
                            else
                            {
                                player thread TellPlayer(InsufficientPermissionError(player GetPlayerPermissionLevel(), args[0], commandValue["permission"]), 1.5);
                            }
                        }
                        else
                        {
                            if (args[0] == "commands")
                            {
                                player thread TellPlayer(CommandHelpDoesNotExistError(args[0]), 1);
                            }
                            else
                            {
                                player thread TellPlayer(CommandDoesNotExistError(args[0]), 1);
                            }
                        }
                    }
                }
                // any other command
                else
                {
                    commandName = GetSubStr(command, 1);
                    commandValue = level.commands[GetDvar("net_port")][commandName];

                    if (IsDefined(commandValue))
                    {
                        if (!PermissionIsEnabled() || PlayerHasSufficientPermissions(player, commandValue["permission"]))
                        {
                            if (commandValue["type"] == "text")
                            {
                                player thread TellPlayer(commandValue["text"], 2);
                            }
                            else if (commandValue["type"] == "function")
                            {
                                error = player [[commandValue["function"]]](args);

                                if (IsDefined(error))
                                {
                                    player thread TellPlayer(error, 1.5);
                                }
                            }
                        }
                        else
                        {
                            player thread TellPlayer(InsufficientPermissionError(player GetPlayerPermissionLevel(), commandName, commandValue["permission"]), 1.5);
                        }
                    }
                    else
                    {
                        player thread TellPlayer(CommandDoesNotExistError(commandName), 1);
                    }
                }
            }
        }
        else
        {
            player thread TellPlayer(level.chat_commands["no_commands_message"], level.chat_commands["no_commands_wait"], false);
        }
    }
}

TellPlayer(messages, waitTime, isCommand)
{
    for (i = 0; i < messages.size; i++)
    {
        message = messages[i];

        if (IsDefined(isCommand) && isCommand)
        {
            message = GetDvar("cc_prefix") + message;
        }
        
        self IPrintLnBold(message);
        
        if (i < (messages.size - 1)) // Don't unnecessarily wait after the last message has been displayed
        {
            wait waitTime;
        }
    }
}



/* Player section */

OnPlayerConnect()
{
    for(;;)
    {
		level waittill("connected", player);

        if (player IsBot())
        {
            continue; // stop
        }

        if (!IsDefined(player.pers["chat_commands"]))
        {
            player.pers["chat_commands"] = [];

            if (DebugIsOn())
            {
                Print("GUID of " + player.name + ": " + player.guid);
            }
        }

        player SetPlayerPermissionLevel(player GetPlayerPermissionLevelFromDvar());
    }
}



/* Error functions section */

CommandDoesNotExistError(commandName)
{
    return array("The command " + commandName + " doesn't exist", "Type " + GetDvar("cc_prefix") + "commands to get a list of commands");
}

CommandHelpDoesNotExistError(commandName)
{
    return array("The command " + commandName + " doesn't have any help message");
}

InsufficientPermissionError(playerPermissionLevel, commandName, requiredPermissionLevel)
{
    if (playerPermissionLevel == 0)
    {
        return array("You don't have the permissions to run any command");
    }
    
    return array("Access to the ^5" + commandName + " ^7command refused", "Your permission level is ^5" + playerPermissionLevel + " ^7and the minimum permission level for this command is ^5" + requiredPermissionLevel);
}

InvalidPermissionLevelError(requestedPermissionLevel)
{
    return array("^5" + requestedPermissionLevel + " ^7is not a valid permission level", "Permission levels range from ^50 ^7to ^5" + GetDvarInt("cc_permission_max"));
}

NotEnoughArgsError(minimumArgs)
{
    return array("Not enough arguments supplied", "At least " + minimumArgs + " argument expected");
}

PlayerDoesNotExistError(playerName)
{
    return array("Player " + playerName + " was not found");
}

DvarDoesNotExistError(dvarName)
{
    return array("The dvar " + dvarName + " doesn't exist");
}



/* Utils section */

FindPlayerByName(name)
{
    if (name == "me")
    {
        return self;
    }
    
    foreach (player in level.players)
    {
        playerName = player.name;

        if (IsSubStr(playerName, "]")) // support for clantags
        {
            playerName = StrTok(playerName, "]")[1]; // ignore the clantag
        }

        if (ToLower(playerName) == ToLower(name))
        {
            return player;
        }
    }
}

ToggleStatus(commandName, commandDisplayName, player)
{
    SetStatus(commandName, player, !GetStatus(commandName, player));

    statusMessage = "^2ON";
    
    if (!GetStatus(commandName, player))
    {
        statusMessage = "^1OFF";
    }

    if (self.name == player.name)
    {
        self TellPlayer(array("You changed your " + commandDisplayName + " status to " + statusMessage), 1);
    }
    else
    {
        self TellPlayer(array(player.name + " " + commandDisplayName + " status changed to " + statusMessage), 1);
        player TellPlayer(array(self.name + " changed your " + commandDisplayName + " status to " + statusMessage), 1);
    }
}

GetStatus(commandName, player)
{
    if (!IsDefined(player.pers["chat_commands"])) // avoid undefined errors in the console
    {
        player.pers["chat_commands"] = [];
    }

    if (!IsDefined(player.pers["chat_commands"]["status"])) // avoid undefined errors in the console
    {
        player.pers["chat_commands"]["status"] = [];
    }

    if (!IsDefined(player.pers["chat_commands"]["status"][commandName])) // status is set to OFF/false by default
    {
        SetStatus(commandName, player, false);
    }

    return player.pers["chat_commands"]["status"][commandName];
}

SetStatus(commandName, player, status)
{
    player.pers["chat_commands"]["status"][commandName] = status;
}

GetPlayerPermissionLevelFromDvar()
{
    for (dvarIndex = GetDvarInt("cc_permission_max"); dvarIndex > 0; dvarIndex--)
    {
        dvarName = "cc_permission_" + dvarIndex;

        foreach (value in StrTok(GetDvar(dvarName), ":"))
        {
            if (GetDvar("cc_permission_mode") == "name")
            {
                playerName = self.name;

                if (IsSubStr(playerName, "]")) // support for clantags
                {
                    playerName = StrTok(playerName, "]")[1]; // ignore the clantag
                }

                if (ToLower(value) == ToLower(playerName))
                {
                    return dvarIndex;
                }
            }
            else
            {
                if (value == self.guid)
                {
                    return dvarIndex;
                }
            }
        }
    }

    return GetDvarInt("cc_permission_default");
}

GetPlayerPermissionLevel()
{
    return self.pers["chat_commands"]["permission_level"];
}

SetPlayerPermissionLevel(newPermissionLevel)    
{
    self.pers["chat_commands"]["permission_level"] = newPermissionLevel;
}

PlayerHasSufficientPermissions(player, targetedPermissionLevel)
{
    playerPermissionLevel = player GetPlayerPermissionLevel();

    if (playerPermissionLevel == 0)
    {
        return false;
    }

    if (!IsDefined(targetedPermissionLevel))
    {
        return true;
    }

    return playerPermissionLevel >= targetedPermissionLevel;
}

DvarIsInitialized(dvarName)
{
	result = GetDvar(dvarName);
	return result != "";
}

SetDvarIfNotInitialized(dvarName, dvarValue)
{
	if (!DvarIsInitialized(dvarName))
    {
        SetDvar(dvarName, dvarValue);
    }
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}

TargetIsMyself(targetName)
{
    return targetName == "me" || ToLower(targetName) == ToLower(self.name);
}

AddElementToArray(array, element)
{
    array[array.size] = element;
    return array;
}

DebugIsOn()
{
    return GetDvarInt("cc_debug");
}

PermissionIsEnabled()
{
    return GetDvarInt("cc_permission_enabled");
}
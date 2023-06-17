#include scripts\chat_commands;

Init()
{
    if (PermissionIsEnabled())
    {
        CreateCommand(level.chat_commands["ports"], "getpermission", "function", ::GetPlayerPermissionCommand, 2, array("default_help_one_player"), array("gp"));
        CreateCommand(level.chat_commands["ports"], "setpermission", "function", ::SetPlayerPermissionCommand, 4, [], array("sp"));
    }
}



/* Command section */

GetPlayerPermissionCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = GetPlayerPermission(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}

SetPlayerPermissionCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = SetPlayerPermission(args[0], args[1]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

GetPlayerPermission(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    self thread TellPlayer(array("^5" + player.name + " ^7permission level is ^5" + player GetPlayerPermissionLevel()), 1);
}

SetPlayerPermission(playerName, newPermissionLevel)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    newPermissionLevel = int(newPermissionLevel);

    if (newPermissionLevel < 0 || newPermissionLevel > GetDvarInt("cc_permission_max"))
    {
        return InvalidPermissionLevelError(newPermissionLevel);
    }

    player SetPlayerPermissionLevel(newPermissionLevel);
}
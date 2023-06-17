#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "getdvar", "function", ::GetDvarCommand, 2, [], array("gd"));
    CreateCommand(level.chat_commands["ports"], "setdvar", "function", ::SetDvarCommand, 4, [], array("sd"));
    CreateCommand(level.chat_commands["ports"], "setclientdvar", "function", ::SetPlayerDvarCommand, 4, [], array("scd"));
}



/* Command section */

GetDvarCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = GetServerDvar(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}

SetDvarCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = SetServerDvar(args[0], args[1], false);

    if (IsDefined(error))
    {
        return error;
    }
}

SetPlayerDvarCommand(args)
{
    if (args.size < 3)
    {
        return NotEnoughArgsError(3);
    }

    error = SetPlayerDvar(args[0], args[1], args[2]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

GetServerDvar(dvarName)
{
    if (DvarIsInitialized(dvarName))
    {
        self thread TellPlayer(array("^5" + dvarName + " ^7is currently set to ^5" + GetDvar(dvarName)), 1);
    }
    else
    {
        return DvarDoesNotExistError(dvarName);
    }
}

SetServerDvar(dvarName, dvarValue, canSetUndefinedDvar)
{
    if (IsDefined(canSetUndefinedDvar) && canSetUndefinedDvar)
    {
        SetDvar(dvarName, dvarValue);
    }
    else
    {
        if (DvarIsInitialized(dvarName))
        {
            SetDvar(dvarName, dvarValue);
        }
        else
        {
            return DvarDoesNotExistError(dvarName);
        }
    }
}

SetPlayerDvar(playerName, dvarName, dvarValue)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    player SetClientDvar(dvarName, dvarValue);
}
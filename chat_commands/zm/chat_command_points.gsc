#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "setpoints", "function", ::SetPointsCommand, 3);
    CreateCommand(level.chat_commands["ports"], "addpoints", "function", ::AddPointsCommand, 3);
    CreateCommand(level.chat_commands["ports"], "takepoints", "function", ::TakePointsCommand, 3);
}



/* Command section */

SetPointsCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = SetPlayerPoints(args[0], args[1]);

    if (IsDefined(error))
    {
        return error;
    }
}

AddPointsCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = AddPlayerPoints(args[0], args[1]);

    if (IsDefined(error))
    {
        return error;
    }
}

TakePointsCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = TakePlayerPoints(args[0], args[1]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */ 

SetPlayerPoints(playerName, points)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    player.score = int(points);
}

AddPlayerPoints(playerName, points)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    player.score += int(points);
}

TakePlayerPoints(playerName, points)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    player.score -= int(points);
}
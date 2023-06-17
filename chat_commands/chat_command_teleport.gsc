#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "teleport", "function", ::TeleportCommand, 2, array("default_help_two_players"), array("tp"));
}



/* Command section */

TeleportCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = TeleportPlayer(args[0], args[1]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

TeleportPlayer(teleportedPlayerName, destinationPlayerName)
{
    players = [];
    names = array(teleportedPlayerName, destinationPlayerName);

    for (i = 0; i < names.size; i++)
    {
        name = names[i];

        player = FindPlayerByName(name);

        if (!IsDefined(player))
        {
            return PlayerDoesNotExistError(name);
        }

        players = AddElementToArray(players, player);
    }

    players[0] SetOrigin(players[1].origin);
}
#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "kick", "function", ::KickCommand, 4, array("default_help_one_player"));
}



/* Command section */

KickCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = KickPlayer(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

KickPlayer(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    Kick(player GetEntityNumber());
}
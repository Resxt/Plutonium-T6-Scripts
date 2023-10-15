#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "notarget", "function", ::NoTargetCommand, 3, array("default_help_one_player"), array("ignoreme", "ignore"));
}



/* Command section */

NoTargetCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleNoTarget(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleNoTarget(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "notarget";

    ToggleStatus(commandName, "No Target", player);

    player.ignoreme = GetStatus(commandName, player);
}
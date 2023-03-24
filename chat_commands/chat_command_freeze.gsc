#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "freeze", "function", ::FreezeCommand, 3, array("default_help_one_player"));
}



/* Command section */

FreezeCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleFreeze(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleFreeze(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "freeze";

    ToggleStatus(commandName, "Freeze", player);

    if (GetStatus(commandName, player))
    {
        player DoFreeze(true);
        player thread ThreadFreeze();
    }
    else
    {
        player DoFreeze(false);
        player notify("chat_commands_freeze_off");
    }
}

ThreadFreeze()
{
    self endon("disconnect");
    self endon("chat_commands_freeze_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        self DoFreeze(true);
    }
}

DoFreeze(enabled)
{
    if (enabled)
    {
        self FreezeControls(1);
    }
    else
    {
        self FreezeControls(0);
    }
}
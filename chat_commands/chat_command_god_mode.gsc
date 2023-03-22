#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "god", "function", ::GodModeCommand, 3, array("default_help_one_player"));
}



/* Command section */

GodModeCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleGodMode(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleGodMode(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "god";

    ToggleStatus(commandName, "God Mode", player);

    if (GetStatus(commandName, player))
    {
        player DoGodMode(true);
        player thread ThreadGodMode();
    }
    else
    {
        player DoGodMode(false);
        player notify("chat_commands_god_mode_off");
    }
}

ThreadGodMode()
{
    self endon("disconnect");
    self endon("chat_commands_god_mode_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        self DoGodMode(true);
    }
}

DoGodMode(enabled)
{
    if (enabled)
    {
        self EnableInvulnerability();
    }
    else
    {
        self disableInvulnerability();
    }
}
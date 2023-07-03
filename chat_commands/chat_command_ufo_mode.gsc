#include scripts\chat_commands;

Init()
{
    // change to false to disable death barrier protection
    // in ZM: no death barrier for all players during the entire game
    // in MP: constant god mode for the player who's in UFO mode until toggling ufo off
    level.chat_commands_protect_from_death_barriers = true;

    if (level.chat_commands_protect_from_death_barriers && !IsMultiplayerMode())
    {
        level.player_out_of_playable_area_monitor = false;
    }

    CreateCommand(level.chat_commands["ports"], "ufomode", "function", ::UfoModeCommand, 3, array("default_help_one_player"), array("ufo"));
}



/* Command section */

UfoModeCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleUfoMode(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleUfoMode(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "ufo";

    ToggleStatus(commandName, "Ufo Mode", player);

    if (GetStatus(commandName, player))
    {
        player thread DoUfoMode();
        player thread ThreadUfoMode();
    }
    else
    {
        player notify("chat_commands_ufo_mode_off");

        if (IsMultiplayerMode() && !GetStatus("god", player))
        {
            self DisableInvulnerability();
        }
    }
}

ThreadUfoMode()
{
    self endon("disconnect");
    self endon("chat_commands_ufo_mode_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        self DoUfoMode();
    }
}

DoUfoMode()
{
    self endon("disconnect");
    self endon("death");
    self endon("chat_commands_ufo_mode_off");

    if (level.chat_commands_protect_from_death_barriers && IsMultiplayerMode())
    {
        self EnableInvulnerability();
    }

    self.fly = 0;
    UFO = Spawn("script_model", self.origin);

    for(;;)
    {
        if(self MeleeButtonPressed())
        {
            self PlayerLinkTo(UFO);
            self.fly = 1;
        }
        else
        {
            self Unlink();
            self.fly = 0;
        }
        if(self.fly == 1)
        {
            fly = self.origin + VectorScale(AnglesToForward(self GetPlayerAngles()), 20);
            UFO MoveTo(fly, .01);
        }

        wait 0.05;
    }
}
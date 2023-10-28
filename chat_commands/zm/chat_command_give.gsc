#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "givepowerup", "function", ::GivePowerupCommand, 2, [], array("spawnpowerup", "powerup", "pu"));
}



/* Command section */

GivePowerupCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = GivePlayerPowerup(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

GivePlayerPowerup(powerupName)
{
    powerupName = ToLower(powerupName);

    if (powerupName == "all")
    {
        foreach (powerup in GetAvailablePowerups())
        {
            level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop(powerup, self.origin);
        }
    }
    else if (powerupName == "allbutnuke" || powerupName == "all_but_nuke" || powerupName == "allnonuke" || powerupName == "all_no_nuke")
    {
        foreach (powerup in GetAvailablePowerups())
        {
            if (powerup != "nuke")
            {
                level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop(powerup, self.origin);
            }
        }
    }
    else
    {
        if (IsValidPowerup(powerupName))
        {
            level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop(powerupName, self.origin);
        }
        else
        {
            return PowerupDoesNotExistError(powerupName);
        }
    }
}

    }
}
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
    if (IsValidPowerup(powerupName))
    {
        level thread maps\mp\zombies\_zm_powerups::specific_powerup_drop(powerupName, self.origin);
    }
    else
    {
        return PowerupDoesNotExistError(powerupName);
    }
}
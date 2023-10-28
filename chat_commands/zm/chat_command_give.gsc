#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "givepowerup", "function", ::GivePowerupCommand, 2, [], array("spawnpowerup", "powerup", "pu"));
    CreateCommand(level.chat_commands["ports"], "giveperk", "function", ::GivePerkCommand, 2, [], array("perk"));
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

GivePerkCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = GivePlayerPerk(args[0], args[1], true, true);

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

GivePlayerPerk(playerName, perkName, enableMusic, enableAnimation)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    if (ToLower(perkName) == "all")
    {
        foreach (perk in GetAvailablePerks())
        {
            player thread maps\mp\zombies\_zm_perks::give_perk(perk, 0);
        }
    }
    else
    {
        perkInfos = GetPerkInfos(perkName);

        if (perkInfos.size > 0)
        {
            if (enableMusic)
            {
                player thread maps\mp\zombies\_zm_audio::play_jingle_or_stinger( perkInfos["music"]);
            }
            
            if (enableAnimation)
            {
                player thread vending_trigger_post_think(player, perkInfos["perk_name"]);
            }
            else
            {
                player thread maps\mp\zombies\_zm_perks::give_perk(perkInfos["perk_name"], 0);
            }
        }
        else
        {
            return PerkDoesNotExistError(perkName);
        }
    }
}
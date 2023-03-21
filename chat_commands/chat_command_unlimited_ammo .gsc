#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "unlimitedammo", "function", ::UnlimitedAmmoCommand, 3, array("default_help_one_player"));
}



/* Command section */

UnlimitedAmmoCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleUnlimitedAmmo(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */ 

ToggleUnlimitedAmmo(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "unlimitedammo";

    ToggleStatus(commandName, "Unlimited Ammo", player);

    if (GetStatus(commandName, player))
    {
        player thread DoUnlimitedAmmo();
        player thread ThreadUnlimitedAmmo();
    }
    else
    {
        player notify("chat_commands_unlimited_ammo_off");
    }
}

ThreadUnlimitedAmmo()
{
    self endon("disconnect");
    self endon("chat_commands_unlimited_ammo_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        self thread DoUnlimitedAmmo();
    }
}

DoUnlimitedAmmo()
{
    self endon("chat_commands_unlimited_ammo_off");
    
    while (true)
    {
        currentWeapon = self getCurrentWeapon();
        currentoffhand = self GetCurrentOffhand();

        if (currentWeapon != "none")
        {
            self SetWeaponAmmoClip(currentWeapon, 9999);
        }

        if (IsSubStr(currentWeapon, "akimbo"))
        {
            self SetWeaponAmmoClip(currentWeapon, 9999, "left");
            self SetWeaponAmmoClip(currentWeapon, 9999, "right");
        }
        
        if ( currentoffhand != "none" )
        {
            self setWeaponAmmoClip( currentoffhand, 9999 );
            self GiveMaxAmmo( currentoffhand );
        }

        wait 0.05;
    }
}
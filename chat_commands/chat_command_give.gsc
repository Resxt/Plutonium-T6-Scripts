#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "giveweapon", "function", ::GiveWeaponCommand, 2);
}



/* Command section */

GiveWeaponCommand(args)
{
    if (args.size < 2)
    {
        return NotEnoughArgsError(2);
    }

    error = GivePlayerWeapon(args[0], args[1], args[2], true, true);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

GivePlayerWeapon(targetedPlayerName, weaponName, camoIndex, takeCurrentWeapon, playSwitchAnimation)
{
    player = FindPlayerByName(targetedPlayerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(targetedPlayerName);
    }

    weaponName = ToLower(weaponName);
    weaponSplitted = StrTok(weaponName, "+");
    weaponName = weaponSplitted[0];
    attachments = weaponSplitted[1];

    if (IsMultiplayerMode())
    {
        if (GetSubStr(weaponName, weaponName.size - 3, weaponName.size) != "_mp")
        {
            weaponName += "_mp";
        }
    }

    if (!IsValidWeapon(weaponName))
    {
        return WeaponDoesNotExistError(weaponName);
    }

    finalCamoIndex = 0;

    if (IsDefined(camoIndex))
    {
        finalCamoIndex = int(camoIndex);
    }

    if (IsDefined(takeCurrentWeapon) && takeCurrentWeapon)
    {
        player TakeWeapon(player GetCurrentWeapon());
    }

    DoGiveWeapon(weaponName, attachments, finalCamoIndex);
    
    if (IsDefined(playSwitchAnimation) && playSwitchAnimation)
    {
        player SwitchToWeapon(weaponName);
    }
    else
    {
        player SetSpawnWeapon(weaponName);
    }
}

DoGiveWeapon(weaponCodeName, attachments, camoIndex)
{
    if (IsDefined(attachments) && attachments != "")
    {
        weaponCodeName = weaponCodeName+ "+" + attachments;
    }

    if (!IsDefined(camoIndex))
    {
        camoIndex = 0;
    }

    self GiveWeapon(weaponCodeName, 0, camoIndex);
}
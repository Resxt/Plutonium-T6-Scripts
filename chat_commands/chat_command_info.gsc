#include scripts\chat_commands;

Init()
{
    if (IsMultiplayerMode())
    {
        CreateCommand(level.chat_commands["ports"], "listattachments", "function", ::ListAttachmentsCommand, 2);
    }

    if (!IsMultiplayerMode())
    {
        CreateCommand(level.chat_commands["ports"], "listpowerups", "function", ::ListPowerupsCommand, 2);
        CreateCommand(level.chat_commands["ports"], "listperks", "function", ::ListPerksCommand, 2);
    }

    CreateCommand(level.chat_commands["ports"], "listweapons", "function", ::ListWeaponsCommand, 2);
}



/* Command section */

ListWeaponsCommand(args)
{
    self thread ListWeapons(args[0]);
}

ListAttachmentsCommand(args)
{
    error = self thread ListAttachments(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}

ListPowerupsCommand(args)
{
    error = self thread ListPowerups();

    if (IsDefined(error))
    {
        return error;
    }
}

ListPerksCommand(args)
{
    error = self thread ListPerks();

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ListWeapons(displayMode)
{
    PrintLn("-------------------------------");
    PrintLn("Available weapons");
    PrintLn("-------------------------------");

    if (IsMultiplayerMode())
    {
        if (IsDefined(displayMode))
        {
            foreach (index in GetArrayKeys(level.tbl_weaponids))
            {
                PrintLn(getweapondisplayname(level.tbl_weaponids[index]["reference"] + "_mp"));
            }
        }
        else
        {
            foreach (index in GetArrayKeys(level.tbl_weaponids))
            {
                PrintLn(level.tbl_weaponids[index]["reference"] + "_mp");
            }
        }
    }
    else
    {
        if (IsDefined(displayMode))
        {
            foreach (weapon in GetArrayKeys(level.zombie_weapons))
            {
                PrintLn(getweapondisplayname(weapon));
            }
        }
        else
        {
            foreach (weapon in GetArrayKeys(level.zombie_weapons))
            {
                PrintLn(weapon);
            }
        }
    }
}

ListAttachments(weaponName)
{
    weaponIndex = 0;
    finalWeaponName = "";

    if (IsDefined(weaponName))
    {
        if (GetSubStr(weaponName, weaponName.size - 3, weaponName.size) != "_mp")
        {
            weaponName += "_mp";
        }

        if (!IsValidWeapon(weaponName))
        {
            return WeaponDoesNotExistError(weaponName);
        }
        
        weaponIndex = getbaseweaponitemindex(weaponName);
        finalWeaponName = weaponName;
    }
    else
    {
        finalWeaponName = self getcurrentweapon();
        weaponIndex = getbaseweaponitemindex(self getcurrentweapon());
    }

    attachments = StrTok(level.tbl_weaponids[weaponIndex]["attachment"], " ");
    attachmentsFinal = [];

    // remove everything after _ in attachments name as this was always returning wrong names
    // for example it would return silencer_shotgun when the actual codename is just silencer etc
    foreach (attachment in attachments)
    {
        attachmentsFinal = AddElementToArray(attachmentsFinal, StrTok(attachment, "_")[0]);
    }

    PrintLn("-------------------------------");
    PrintLn("Available attachments for " + getweapondisplayname(finalWeaponName) + " (" + StrTok(finalWeaponName, "_mp")[0] + "_mp" + ")");
    PrintLn("-------------------------------");

    foreach (attachment in attachmentsFinal)
    {
        PrintLn(attachment);
    }
}

ListPowerups()
{
    powerups = GetAvailablePowerups();

    self thread TellPlayer(powerups, 2);

    PrintLn("-------------------------------");
    PrintLn("Available powerups");
    PrintLn("-------------------------------");

    foreach (powerup in powerups)
    {
        PrintLn(powerup);
    }
}

ListPerks()
{
    perks = GetAvailablePerks();

    self thread TellPlayer(perks, 2);

    PrintLn("-------------------------------");
    PrintLn("Available perks");
    PrintLn("-------------------------------");

    foreach (perk in perks)
    {
        PrintLn(perk);
    }
}
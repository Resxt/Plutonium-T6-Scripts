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
    waitTime = 1.5;

    if (IsMultiplayerMode())
    {
        if (IsDefined(displayMode))
        {
            foreach (index in GetArrayKeys(level.tbl_weaponids))
            {
                self thread TellPlayer(array(getweapondisplayname(level.tbl_weaponids[index]["reference"] + "_mp")), waitTime);
                wait waitTime;
            }
        }
        else
        {
            foreach (index in GetArrayKeys(level.tbl_weaponids))
            {
                self thread TellPlayer(array(level.tbl_weaponids[index]["reference"] + "_mp"), waitTime);
                wait waitTime;
            }
        }
    }
    else
    {
        if (IsDefined(displayMode))
        {
            foreach (weapon in GetArrayKeys(level.zombie_weapons))
            {
                self thread TellPlayer(array(getweapondisplayname(weapon)), waitTime);
                wait waitTime;
            }
        }
        else
        {
            foreach (weapon in GetArrayKeys(level.zombie_weapons))
            {
                self thread TellPlayer(array(weapon), waitTime);
                wait waitTime;
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

    self thread TellPlayer(attachmentsFinal, 2);

    if (DebugIsOn())
    {
        Print("-------------------------------");
        Print("Available attachments for " + getweapondisplayname(finalWeaponName) + " (" + StrTok(finalWeaponName, "_mp")[0] + "_mp" + ")");

        foreach (attachment in attachmentsFinal)
        {
            Print(attachment);
        }
    }
}

ListPowerups()
{
    self thread TellPlayer(GetAvailablePowerups(), 2);
}

ListPerks()
{
    self thread TellPlayer(GetAvailablePerks(), 2);
}
#include scripts\chat_commands;

Init()
{
    if (IsMultiplayerMode())
    {
        CreateCommand(level.chat_commands["ports"], "listattachments", "function", ::ListAttachmentsCommand, 2);
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
    }
    else
    {
        weaponIndex = getbaseweaponitemindex(self getcurrentweapon());
    }

    self thread TellPlayer(StrTok(level.tbl_weaponids[weaponIndex]["attachment"], " "), 2);
}
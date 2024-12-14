/*
======================================================================
|                         Game: Plutonium T6 	                     |
|                   Description : Let players vote                   |
|              for a map and mode at the end of each game            |
|                            Author: Resxt                           |
======================================================================
|   https://github.com/Resxt/Plutonium-T6-Scripts/tree/main/mapvote  |
======================================================================
*/

#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes_zm\_hud_util;
#include common_scripts\utility;
#include maps\mp\_utility;

/* Entry point */

Main()
{
    SetDvarIfNotInitialized("mapvote_enable", true);
}

Init()
{
    if (GetDvarInt("mapvote_enable"))
    {
        level.mapvote_rotate_function = ::StartRotation;

        InitMapvote();
    }
}



/* Init section */

InitMapvote()
{
    InitDvars();
    InitVariables();

    if (GetDvarInt("mapvote_debug"))
    {
        Print("[MAPVOTE] Debug mode is ON");
        wait 3;
        level thread StartVote();
        level thread ListenForEndVote();
    }
    else
    {
        // Starting the mapvote normally is handled in mp\mapvote_mp_extend.gsc and zm\mapvote_zm_extend.gsc
    }
}

InitDvars()
{
    SetDvarIfNotInitialized("mapvote_debug", false);

    if (IsMultiplayerMode())
    {
        SetDvarIfNotInitialized("mapvote_maps", "Aftermath:Cargo:Carrier:Drone:Express:Hijacked:Meltdown:Overflow:Plaza:Raid:Slums:Standoff:Turbine:Yemen:Nuketown:Downhill:Mirage:Hydro:Grind:Encore:Magma:Vertigo:Studio:Uplink:Detour:Cove:Rush:Dig:Frost:Pod:Takeoff");
        SetDvarIfNotInitialized("mapvote_modes", "Team Deathmatch,tdm:Domination,dom:Hardpoint,koth");
        SetDvarIfNotInitialized("mapvote_limits_maps", 0);
        SetDvarIfNotInitialized("mapvote_limits_modes", 0);
        SetDvarIfNotInitialized("mapvote_sounds_menu_enabled", 1);
        SetDvarIfNotInitialized("mapvote_sounds_timer_enabled", 1);
        SetDvarIfNotInitialized("mapvote_default_rotation_maps", "Hijacked:Raid:Nuketown");
        SetDvarIfNotInitialized("mapvote_default_rotation_modes", "tdm");
    }
    else
    {
        SetDvarIfNotInitialized("mapvote_maps", "Bus Depot,Bus Depot,zm_standard_transit:Town,Town,zm_standard_town:Farm,Farm,zm_standard_farm:Mob of The Dead,Mob of The Dead,zm_classic_prison:Nuketown,Nuketown,zm_standard_nuked:Origins,Origins,zm_classic_tomb:Buried,Buried,zm_classic_processing:Die Rise,Die Rise,zm_classic_rooftop");
        SetDvarIfNotInitialized("mapvote_default_rotation_maps", "Town,zm_standard_town:Farm,zm_standard_farm");
    }
    
    SetDvarIfNotInitialized("mapvote_limits_max", 12);
    SetDvarIfNotInitialized("mapvote_colors_selected", "blue");
    SetDvarIfNotInitialized("mapvote_colors_unselected", "white");
    SetDvarIfNotInitialized("mapvote_colors_timer", "blue");
    SetDvarIfNotInitialized("mapvote_colors_timer_low", "red");
    SetDvarIfNotInitialized("mapvote_colors_help_text", "white");
    SetDvarIfNotInitialized("mapvote_colors_help_accent", "blue");
    SetDvarIfNotInitialized("mapvote_colors_help_accent_mode", "standard");
    SetDvarIfNotInitialized("mapvote_vote_time", 30);
    SetDvarIfNotInitialized("mapvote_blur_level", 2.5);
    SetDvarIfNotInitialized("mapvote_blur_fade_in_time", 2);
    SetDvarIfNotInitialized("mapvote_horizontal_spacing", 75);
    SetDvarIfNotInitialized("mapvote_display_wait_time", 1);
    SetDvarIfNotInitialized("mapvote_default_rotation_enable", false);
    SetDvarIfNotInitialized("mapvote_default_rotation_min_players", 0);
    SetDvarIfNotInitialized("mapvote_default_rotation_max_players", 0);
}

InitVariables()
{
    mapsArray = StrTok(GetDvar("mapvote_maps"), ":");
    voteLimits = [];

    if (IsMultiplayerMode())
    {
        modesArray = StrTok(GetDvar("mapvote_modes"), ":");

        if (GetDvarInt("mapvote_limits_maps") == 0 && GetDvarInt("mapvote_limits_modes") == 0)
        {
            voteLimits = GetVoteLimits(mapsArray.size, modesArray.size);
        }
        else if (GetDvarInt("mapvote_limits_maps") > 0 && GetDvarInt("mapvote_limits_modes") == 0)
        {
            voteLimits = GetVoteLimits(GetDvarInt("mapvote_limits_maps"), modesArray.size);
        }
        else if (GetDvarInt("mapvote_limits_maps") == 0 && GetDvarInt("mapvote_limits_modes") > 0)
        {
            voteLimits = GetVoteLimits(mapsArray.size, GetDvarInt("mapvote_limits_modes"));
        }
        else
        {
            voteLimits = GetVoteLimits(GetDvarInt("mapvote_limits_maps"), GetDvarInt("mapvote_limits_modes"));
        }

        level.mapvote["limit"]["maps"] = voteLimits["maps"];
        level.mapvote["limit"]["modes"] = voteLimits["modes"];
    }
    else
    {
        if (GetDvarInt("mapvote_limits_maps") == 0)
        {
            level.mapvote["limit"]["maps"] = GetVoteLimits(mapsArray.size);
        }
        else
        {
            level.mapvote["limit"]["maps"] = GetVoteLimits(GetDvarInt("mapvote_limits_maps"));
        }
    }

    SetMapvoteData("map");
    
    if (IsMultiplayerMode())
    {
        SetMapvoteData("mode");
    }

    level.mapvote["vote"]["maps"] = [];
    level.mapvote["vote"]["modes"] = [];
    level.mapvote["hud"]["maps"] = [];
    level.mapvote["hud"]["modes"] = [];
}



/* Player section */

/*
This is used instead of notifyonplayercommand("mapvote_up", "speed_throw") 
to fix an issue where players using toggle ads would have to press right click twice for it to register one right click.
With this instead it keeps scrolling every 0.25s until they right click again which is a better user experience
*/
ListenForRightClick()
{
    self endon("disconnect");

    while (true)
    {
        if (self AdsButtonPressed())
        {
            self notify("mapvote_up");
            wait 0.25;
        }

        wait 0.05;
    }
}

ListenForVoteInputs()
{
    self endon("disconnect");

    self thread ListenForRightClick();

    self notifyonplayercommand("mapvote_down", "+attack");
    self notifyonplayercommand("mapvote_select", "+gostand");
    self notifyonplayercommand("mapvote_unselect", "+usereload");
    self notifyonplayercommand("mapvote_unselect", "+activate");
    
    if (GetDvarInt("mapvote_debug"))
    {
        self notifyonplayercommand("mapvote_debug", "+melee");
    }

    while(true)
    {
        input = self waittill_any_return("mapvote_down", "mapvote_up", "mapvote_select", "mapvote_unselect", "mapvote_debug");

        section = self.mapvote["vote_section"];

        if (section == "end" && input != "mapvote_unselect" && input != "mapvote_debug")
        {
            continue; // stop/skip execution
        }
        else if (section == "mode" && level.mapvote["modes"]["by_index"].size <= 1 && input != "mapvote_unselect" && input != "mapvote_debug")
        {
            continue; // stop/skip execution
        }
        else if (section == "mode" && level.mapvote["maps"]["by_index"].size <= 1 && input == "mapvote_unselect")
        {
            continue; // stop/skip execution
        }

        if (input == "mapvote_down")
        {
            if (self.mapvote[section]["hovered_index"] < (level.mapvote[section + "s"]["by_index"].size - 1))
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("uin_start_count_down");
                }

                self UpdateSelection(section, (self.mapvote[section]["hovered_index"] + 1));
            }
        }
        else if (input == "mapvote_up")
        {
            if (self.mapvote[section]["hovered_index"] > 0)
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("uin_start_count_down");
                }

                self UpdateSelection(section, (self.mapvote[section]["hovered_index"] - 1));
            }
        }
        else if (input == "mapvote_select")
        {
            if (GetDvarInt("mapvote_sounds_menu_enabled"))
            {
                self playlocalsound("mpl_killconfirm_tags_pickup");
            }

            self ConfirmSelection(section);
        }
        else if (input == "mapvote_unselect")
        {
            if (section != "map")
            {
                if (GetDvarInt("mapvote_sounds_menu_enabled"))
                {
                    self playlocalsound("fly_betty_jump");
                }

                self CancelSelection(section);
            }
        }
        else if (input == "mapvote_debug" && GetDvarInt("mapvote_debug"))
        {
            Print("--------------------------------");

            foreach (player in GetHumanPlayers())
            {
                if (player.mapvote["map"]["selected_index"] == -1)
                {
                    Print(player.name + " did not vote for any map");
                }
                else
                {
                    mapName = "";

                    if (IsMultiplayerMode())
                    {
                        mapName = level.mapvote["maps"]["by_index"][player.mapvote["map"]["selected_index"]];
                    }
                    else
                    {
                        mapName = level.mapvote["maps"]["by_index"][player.mapvote["map"]["selected_index"]][0];
                    }

                    Print(player.name + " voted for map [" + player.mapvote["map"]["selected_index"] +"] " + mapName);
                }

                if (IsMultiplayerMode())
                {
                    if (player.mapvote["mode"]["selected_index"] == -1)
                    {
                        Print(player.name + " did not vote for any mode");
                    }
                    else
                    {
                        Print(player.name + " voted for mode [" + player.mapvote["mode"]["selected_index"] + "] " + level.mapvote["modes"]["by_index"][player.mapvote["mode"]["selected_index"]]);
                    }
                }
            }
        }

        wait 0.05;
    }
}

OnPlayerDisconnect()
{
    self waittill("disconnect");

    if (self.mapvote["map"]["selected_index"] != -1)
    {
        level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]] = (level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]] - 1);
        level.mapvote["hud"]["maps"][self.mapvote["map"]["selected_index"]] SetValue(level.mapvote["vote"]["maps"][self.mapvote["map"]["selected_index"]]);
    }

    if (self.mapvote["mode"]["selected_index"] != -1)
    {
        level.mapvote["vote"]["modes"][self.mapvote["mode"]["selected_index"]] = (level.mapvote["vote"]["modes"][self.mapvote["mode"]["selected_index"]] - 1);
        level.mapvote["hud"]["modes"][self.mapvote["mode"]["selected_index"]] SetValue(level.mapvote["vote"]["modes"][self.mapvote["mode"]["selected_index"]]);
    }
}


/* Vote section */

CreateVoteMenu()
{
    spacing = 20;
    hudLastPosY = 0;
    
    if (IsMultiplayerMode())
    {
        sectionsSeparation = 0;

        if (level.mapvote["modes"]["by_index"].size > 1 && level.mapvote["maps"]["by_index"].size > 1)
        {
            sectionsSeparation = 1;
        }

        hudLastPosY = -((((level.mapvote["maps"]["by_index"].size + level.mapvote["modes"]["by_index"].size + sectionsSeparation) * spacing) / 2) - (spacing / 2));
    }
    else
    {
        hudLastPosY = -(((level.mapvote["maps"]["by_index"].size * spacing) / 2) - (spacing / 2));
    }

    if (level.mapvote["maps"]["by_index"].size > 1)
    {
        for (mapIndex = 0; mapIndex < level.mapvote["maps"]["by_index"].size; mapIndex++)
        {
            mapVotesHud = CreateHudText("", "objective", 1.5, "LEFT", "CENTER", GetDvarInt("mapvote_horizontal_spacing"), hudLastPosY, true, 0);
            mapVotesHud.color = GetGscColor(GetDvar("mapvote_colors_selected"));

            level.mapvote["hud"]["maps"][mapIndex] = mapVotesHud;

            foreach (player in GetHumanPlayers())
            {
                mapName = "";

                if (IsMultiplayerMode())
                {
                    mapName = level.mapvote["maps"]["by_index"][mapIndex];
                }
                else
                {
                    mapName = level.mapvote["maps"]["by_index"][mapIndex][0];
                }

                player.mapvote["map"][mapIndex]["hud"] = player CreateHudText(mapName, "objective", 1.5, "LEFT", "CENTER", -(GetDvarInt("mapvote_horizontal_spacing")), hudLastPosY);

                if (mapIndex == 0)
                {
                    player UpdateSelection("map", 0);
                }
                else
                {
                    SetElementUnselected(player.mapvote["map"][mapIndex]["hud"]);
                }
            }

            hudLastPosY += spacing;
        }
    }

    if (IsMultiplayerMode() && level.mapvote["modes"]["by_index"].size > 1)
    {
        hudLastPosY += spacing; // Space between maps and modes sections

        for (modeIndex = 0; modeIndex < level.mapvote["modes"]["by_index"].size; modeIndex++)
        {
            modeVotesHud = CreateHudText("", "objective", 1.5, "LEFT", "CENTER", GetDvarInt("mapvote_horizontal_spacing"), hudLastPosY, true, 0);
            modeVotesHud.color = GetGscColor(GetDvar("mapvote_colors_selected"));

            level.mapvote["hud"]["modes"][modeIndex] = modeVotesHud;

            foreach (player in GetHumanPlayers())
            {
                player.mapvote["mode"][modeIndex]["hud"] = player CreateHudText(level.mapvote["modes"]["by_index"][modeIndex], "objective", 1.5, "LEFT", "CENTER", -(GetDvarInt("mapvote_horizontal_spacing")), hudLastPosY);

                SetElementUnselected(player.mapvote["mode"][modeIndex]["hud"]);
            }

            hudLastPosY += spacing;
        }

        if (level.mapvote["maps"]["by_index"].size <= 1)
        {
            player UpdateSelection("mode", 0);
        }
    }

    foreach(player in GetHumanPlayers())
    {
        player.mapvote["map"]["selected_index"] = -1;
        player.mapvote["mode"]["selected_index"] = -1;

        buttonsHelpMessage = "";

        if (GetDvar("mapvote_colors_help_accent_mode") == "standard")
        {
            buttonsHelpMessage = GetChatColor(GetDvar("mapvote_colors_help_text")) + "Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+attack}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go down - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+speed_throw}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go up - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+gostand}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to select - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+activate}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to undo";
        }
        else if(GetDvar("mapvote_colors_help_accent_mode") == "max")
        {
            buttonsHelpMessage = GetChatColor(GetDvar("mapvote_colors_help_text")) + "Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+attack}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "down " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+speed_throw}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to go " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "up " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+gostand}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "select " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "- Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+activate}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "undo";
        }

        if (GetDvarInt("mapvote_debug"))
        {
            if (GetDvar("mapvote_colors_help_accent_mode") == "standard")
            {
                buttonsHelpMessage = buttonsHelpMessage + " - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+melee}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to debug";
            }
            else if(GetDvar("mapvote_colors_help_accent_mode") == "max")
            {
                buttonsHelpMessage = buttonsHelpMessage + GetChatColor(GetDvar("mapvote_colors_help_text")) + " - Press " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "[{+melee}] " + GetChatColor(GetDvar("mapvote_colors_help_text")) + "to " + GetChatColor(GetDvar("mapvote_colors_help_accent")) + "debug";
            }
        }

        player CreateHudText(buttonsHelpMessage, "objective", 1.5, "CENTER", "CENTER", 0, 210); 
    }
}

CreateVoteTimer()
{
	soundFX = spawn("script_origin", (0,0,0));
	soundFX hide();
	
	timerhud = CreateTimer(GetDvarInt("mapvote_vote_time"), &"Vote ends in: ", "objective", 1.5, "CENTER", "CENTER", 0, -210);		
    timerhud.color = GetGscColor(GetDvar("mapvote_colors_timer"));
	for (i = GetDvarInt("mapvote_vote_time"); i > 0; i--)
	{	
		if(i <= 5) 
		{
			timerhud.color = GetGscColor(GetDvar("mapvote_colors_timer_low"));

            if (GetDvarInt("mapvote_sounds_timer_enabled"))
            {
                soundFX playSound( "mpl_ui_timer_countdown" );
            }
		}
		wait(1);
	}	
	level notify("mapvote_vote_end");
}

StartVote()
{
    level endon("end_game");

    for (i = 0; i < level.mapvote["maps"]["by_index"].size; i++)
    {
        level.mapvote["vote"]["maps"][i] = 0;
    }

    if (IsMultiplayerMode())
    {
        for (i = 0; i < level.mapvote["modes"]["by_index"].size; i++)
        {
            level.mapvote["vote"]["modes"][i] = 0;
        }
    }

    level thread CreateVoteMenu();
    level thread CreateVoteTimer();

    foreach (player in GetHumanPlayers())
    {
        player FreezeControlsAllowLook(1);
        player SetBlur(GetDvarInt("mapvote_blur_level"), GetDvarInt("mapvote_blur_fade_in_time"));

        player thread ListenForVoteInputs();
        player thread OnPlayerDisconnect();
    }
}

ListenForEndVote()
{
    level endon("end_game");
    level waittill("mapvote_vote_end");

    mostVotedMapIndex = 0;
    mostVotedMapVotes = 0;
    mostVotedModeIndex = 0;
    mostVotedModeVotes = 0;

    foreach (mapIndex in GetArrayKeys(level.mapvote["vote"]["maps"]))
    {
        if (level.mapvote["vote"]["maps"][mapIndex] > mostVotedMapVotes)
        {
            mostVotedMapIndex = mapIndex;
            mostVotedMapVotes = level.mapvote["vote"]["maps"][mapIndex];
        }
    }

    foreach (modeIndex in GetArrayKeys(level.mapvote["vote"]["modes"]))
    {
        if (level.mapvote["vote"]["modes"][modeIndex] > mostVotedModeVotes)
        {
            mostVotedModeIndex = modeIndex;
            mostVotedModeVotes = level.mapvote["vote"]["modes"][modeIndex];
        }
    }

    if (mostVotedMapVotes == 0)
    {
        mostVotedMapIndex = GetRandomElementInArray(GetArrayKeys(level.mapvote["vote"]["maps"]));

        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] No vote for map. Chosen random map index: " + mostVotedMapIndex);
        }
    }
    else
    {
        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] Most voted map has " + mostVotedMapVotes + " votes. Most voted map index: " + mostVotedMapIndex);
        }
    }

    if (mostVotedModeVotes == 0)
    {
        mostVotedModeIndex = GetRandomElementInArray(GetArrayKeys(level.mapvote["vote"]["modes"]));

        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] No vote for mode. Chosen random mode index: " + mostVotedModeIndex);
        }
    }
    else
    {
        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] Most voted mode has " + mostVotedModeVotes + " votes. Most voted mode index: " + mostVotedModeIndex);
        }
    }

    modeName = "";
    modeCfg = "";
    mapName = "";

    if (IsMultiplayerMode())
    {
        modeName = level.mapvote["modes"]["by_index"][mostVotedModeIndex];
        modeCfg = level.mapvote["modes"]["by_name"][level.mapvote["modes"]["by_index"][mostVotedModeIndex]];
        mapName = GetMapCodeName(level.mapvote["maps"]["by_index"][mostVotedMapIndex]);
    }
    else
    {
        modeCfg = level.mapvote["maps"]["by_index"][mostVotedMapIndex][2];
        mapName = GetMapCodeName(level.mapvote["maps"]["by_index"][mostVotedMapIndex][1]);
    }

    if (GetDvarInt("mapvote_debug"))
    {
        Print("[MAPVOTE] mapName: " + mapName);
        Print("[MAPVOTE] modeName: " + modeName);
        Print("[MAPVOTE] modeCfg: " + modeCfg);
        Print("[MAPVOTE] Rotating to " + mapName + " | " + modeName + " (" + modeCfg + ".cfg)");
    }

    DoRotation(modeCfg, mapName);
}

SetMapvoteData(type)
{
    limit = level.mapvote["limit"][type + "s"];

    availableElements = StrTok(GetDvar("mapvote_" + type + "s"), ":");

    if (availableElements.size < limit)
    {
        limit = availableElements.size;
    }

    if (type == "map")
    {
        if (IsMultiplayerMode())
        {
            level.mapvote["maps"]["by_index"] = GetRandomUniqueElementsInArray(availableElements, limit);
        }
        else
        {
            zombiesArrays = GetRandomUniqueElementsInArray(availableElements, limit);

            level.mapvote["maps"]["by_index"] = [];
            
            foreach (element in zombiesArrays)
            {
                splittedElement = StrTok(element, ",");
                level.mapvote["maps"]["by_index"] = AddElementToArray(level.mapvote["maps"]["by_index"], array(splittedElement[0], splittedElement[1], splittedElement[2]));
            }
        }
    }
    else if (type == "mode")
    {
        finalElements = [];

        foreach (mode in GetRandomUniqueElementsInArray(availableElements, limit))
        {
            splittedMode = StrTok(mode, ",");
            finalElements = AddElementToArray(finalElements, splittedMode[0]);

            level.mapvote["modes"]["by_name"][splittedMode[0]] = splittedMode[1];
        }

        level.mapvote["modes"]["by_index"] = finalElements;
    }
}

/*
Gets the amount of maps and modes to display on screen
This is used to get default values if the limits dvars are not set
It will dynamically adjust the amount of maps and modes to show
*/
GetVoteLimits(mapsAmount, modesAmount)
{
    maxLimit = GetDvarInt("mapvote_limits_max");
    limits = [];

    if (!IsDefined(modesAmount))
    {
        if (mapsAmount <= maxLimit)
        {
            return mapsAmount;
        }
        else
        {
            return maxLimit;
        }
    }

    if ((mapsAmount + modesAmount) <= maxLimit)
    {
        limits["maps"] = mapsAmount;
        limits["modes"] = modesAmount;
    }
    else
    {
        if (mapsAmount >= (maxLimit / 2) && modesAmount >= (maxLimit))
        {
            limits["maps"] = (maxLimit / 2);
            limits["modes"] = (maxLimit / 2);
        }
        else
        {
            if (mapsAmount > (maxLimit / 2))
            {
                finalMapsAmount = 0;

                if (modesAmount <= 1)
                {
                    limits["maps"] = maxLimit;
                }
                else
                {
                    limits["maps"] = (maxLimit - modesAmount);
                }
                
                limits["modes"] = modesAmount;
            }
            else if (modesAmount > (maxLimit / 2))
            {
                limits["maps"] = mapsAmount;
                limits["modes"] = (maxLimit - mapsAmount);
            }
        }
    }
    
    return limits;
}

RotateDefault()
{
    mapName = "";
    modeCfg = "";

    if (IsMultiplayerMode())
    {
        modeCfg = GetRandomElementInArray(StrTok(GetDvar("mapvote_default_rotation_modes"), ":"));
        mapName = GetMapCodeName(GetRandomElementInArray(StrTok(GetDvar("mapvote_default_rotation_maps"), ":")));
    }
    else
    {
        data = GetRandomElementInArray(StrTok(GetDvar("mapvote_default_rotation_maps"), ":"));
        dataSplitted = StrTok(data, ",");

        modeCfg = dataSplitted[1];
        mapName = GetMapCodeName(dataSplitted[0]);
    }

    DoRotation(modeCfg, mapName);
}

DoRotation(modeCfg, mapName)
{
    SetDvar("sv_maprotationcurrent", "execgts " + modeCfg + ".cfg map " + mapName);
    SetDvar("sv_maprotation", "execgts " + modeCfg + ".cfg map " + mapName);
}

StartRotation()
{
    humanPlayersCount = GetHumanPlayers().size;
    
	if (GetDvarInt("mapvote_default_rotation_enable") && humanPlayersCount >= GetDvarInt("mapvote_default_rotation_min_players") && humanPlayersCount <= GetDvarInt("mapvote_default_rotation_max_players"))
	{
		RotateDefault();
	}
	else
	{
        StartVote();
        ListenForEndVote();
	}
}



/* HUD section */

UpdateSelection(type, index)
{
    if (type == "map" || type == "mode")
    {
        if (!IsDefined(self.mapvote[type]["hovered_index"]))
        {
            self.mapvote[type]["hovered_index"] = 0;
        }

        self.mapvote["vote_section"] = type;

        SetElementUnselected(self.mapvote[type][self.mapvote[type]["hovered_index"]]["hud"]); // Unselect previous element
        SetElementSelected(self.mapvote[type][index]["hud"]); // Select new element

        self.mapvote[type]["hovered_index"] = index; // Update the index
    }
    else if (type == "end")
    {
        self.mapvote["vote_section"] = "end";
    }
}

ConfirmSelection(type)
{
    self.mapvote[type]["selected_index"] = self.mapvote[type]["hovered_index"];
    level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]] = (level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]] + 1);
    level.mapvote["hud"][type + "s"][self.mapvote[type]["selected_index"]] SetValue(level.mapvote["vote"][type + "s"][self.mapvote[type]["selected_index"]]);

    if (type == "map")
    {
        modeIndex = 0;

        if (IsDefined(self.mapvote["mode"]["hovered_index"]))
        {
            modeIndex = self.mapvote["mode"]["hovered_index"];
        }

        self UpdateSelection("mode", modeIndex);
    }
    else if (type == "mode")
    {
        self UpdateSelection("end");
    }
}

CancelSelection(type)
{
    typeToCancel = "";

    if (type == "mode")
    {
        typeToCancel = "map";
    }
    else if (type == "end")
    {
        typeToCancel = "mode";
    }

    level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] = (level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] - 1);
    level.mapvote["hud"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]] SetValue(level.mapvote["vote"][typeToCancel + "s"][self.mapvote[typeToCancel]["selected_index"]]);

    self.mapvote[typeToCancel]["selected_index"] = -1;

    if (type == "mode")
    {
        SetElementUnselected(self.mapvote["mode"][self.mapvote["mode"]["hovered_index"]]["hud"]);
        self.mapvote["vote_section"] = "map";
    }
    else if (type == "end")
    {
        self.mapvote["vote_section"] = "mode";
    }
}

SetElementSelected(element)
{
    element.color = GetGscColor(GetDvar("mapvote_colors_selected"));
}

SetElementUnselected(element)
{
    element.color = GetGscColor(GetDvar("mapvote_colors_unselected"));
}

CreateHudText(text, font, fontScale, relativeToX, relativeToY, relativeX, relativeY, isServer, value)
{
    hudText = "";

    if (IsDefined(isServer) && isServer)
    {
        hudText = CreateServerFontString( font, fontScale );
    }
    else
    {
        hudText = CreateFontString( font, fontScale );
    }

    if (IsDefined(value))
    {
        hudText.label = text;
        hudText SetValue(value);
    }
    else
    {
        hudText SetText(text);
    }

    hudText SetPoint(relativeToX, relativeToY, relativeX, relativeY);
    
    hudText.hideWhenInMenu = 1;
    hudText.glowAlpha = 0;

    return hudText;
}

CreateTimer(time, label, font, fontScale, relativeToX, relativeToY, relativeX, relativeY)
{
	timer = createServerTimer(font, fontScale);	
	timer setpoint(relativeToX, relativeToY, relativeX, relativeY);
	timer.label = label; 
    timer.hideWhenInMenu = 1;
    timer.glowAlpha = 0;
	timer setTimer(time);
	
	return timer;
}



/* Utils section */

SetDvarIfNotInitialized(dvar, value)
{
	if (!IsInitialized(dvar))
    {
        SetDvar(dvar, value);
    }
}

IsInitialized(dvar)
{
	result = GetDvar(dvar);
	return result != "";
}

IsBot()
{
    return IsDefined(self.pers["isBot"]) && self.pers["isBot"];
}

IsMultiplayerMode()
{
    return !IsDefined(level.zombiemode) || !level.zombiemode;
}

GetHumanPlayers()
{
    humanPlayers = [];

    foreach (player in level.players)
    {
        if (!player IsBot())
        {
            humanPlayers = AddElementToArray(humanPlayers, player);
        }
    }

    return humanPlayers;
}

GetRandomElementInArray(array)
{
    return array[GetArrayKeys(array)[randomint(array.size)]];
}

GetRandomUniqueElementsInArray(array, limit)
{
    finalElements = [];

    for (i = 0; i < limit; i++)
    {
        findElement = true;

        while (findElement)
        {
            randomElement = GetRandomElementInArray(array);

            if (!ArrayContainsValue(finalElements, randomElement))
            {
                finalElements = AddElementToArray(finalElements, randomElement);

                findElement = false;
            }
        }
    }

    return finalElements;
}

ArrayContainsValue(array, valueToFind)
{
    if (array.size == 0)
    { 
        return false;
    }

    foreach (value in array)
    {
        if (value == valueToFind)
        {
            return true;
        }
    }

    return false;
}

AddElementToArray(array, element)
{
    array[array.size] = element;
    return array;
}

GetMapCodeName(mapName)
{
    formattedMapName = ToUpper(mapName);

    if (IsMultiplayerMode())
    {
        switch(formattedMapName)
        {
            case "NUKETOWN":
            return "mp_nuketown_2020";

            case "HIJACKED":
            return "mp_hijacked";

            case "MELTDOWN":
            return "mp_meltdown";

            case "EXPRESS":
            return "mp_express";

            case "CARRIER":
            return "mp_carrier";

            case "OVERFLOW":
            return "mp_overflow";

            case "SLUMS":
            return "mp_slums";

            case "AFTERMATH":
            return "mp_la";

            case "CARGO":
            return "mp_dockside";

            case "TURBINE":
            return "mp_turbine";

            case "DRONE":
            return "mp_drone";

            case "RAID":
            return "mp_raid";

            case "STANDOFF":
            return "mp_village";

            case "PLAZA":
            return "mp_nightclub";

            case "YEMEN":
            return "mp_socotra";

            case "UPLINK":
            return "mp_uplink";

            case "DETOUR":
            return "mp_bridge";

            case "COVE":
            return "mp_castaway";

            case "RUSH":
            return "mp_paintball";

            case "STUDIO":
            return "mp_studio";

            case "MAGMA":
            return "mp_magma";

            case "VERTIGO":
            return "mp_vertigo";

            case "ENCORE":
            return "mp_concert";

            case "DOWNHILL":
            return "mp_downhill";

            case "GRIND":
            return "mp_skate";

            case "HYDRO":
            return "mp_hydro";

            case "MIRAGE":
            return "mp_mirage";

            case "FROST":
            return "mp_frostbite";

            case "TAKEOFF":
            return "mp_takeoff";

            case "POD":
            return "mp_pod";

            case "DIG":
            return "mp_dig"; 
        }
    }
    else
    {
        switch(formattedMapName)
        {
            case "BURIED":
            return "zm_buried";

            case "DIE RISE":
            return "zm_highrise";

            case "MOB OF THE DEAD":
            return "zm_prison";

            case "NUKETOWN":
            return "zm_nuked";

            case "ORIGINS":
            return "zm_tomb";

            case "TRANZIT":
            case "FARM":
            case "TOWN":
            case "BUS DEPOT":
            return "zm_transit";

            case "DINER":
            return "zm_transit_dr";
        }
    }
}

GetGscColor(colorName)
{
    switch (colorName)
	{
        case "red":
        return (1, 0, 0.059);

        case "green":
        return (0.549, 0.882, 0.043);

        case "yellow":
        return (1, 0.725, 0);

        case "blue":
        return (0, 0.553, 0.973);

        case "cyan":
        return (0, 0.847, 0.922);

        case "purple":
        return (0.427, 0.263, 0.651);

        case "white":
        return (1, 1, 1);

        case "grey":
        case "gray":
        return (0.137, 0.137, 0.137);

        case "black":
        return (0, 0, 0);
	}
}

GetChatColor(colorName)
{
    switch(colorName)
    {
        case "red":
        return "^1";

        case "green":
        return "^2";

        case "yellow":
        return "^3";

        case "blue":
        return "^4";

        case "cyan":
        return "^5";

        case "purple":
        return "^6";

        case "white":
        return "^7";

        case "grey":
        return "^0";

        case "black":
        return "^0";
    }
}

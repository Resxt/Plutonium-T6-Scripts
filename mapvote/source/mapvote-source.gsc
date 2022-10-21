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

Init()
{
    if (GetDvarInt("mapvote_enable"))
    {
        InitMapvote();
    }
}



/* Init section */

InitMapvote()
{
    InitDvars();
    InitVariables();

    level thread ListenForStartVote();
    level thread ListenForEndVote();

    if (GetDvarInt("mapvote_debug"))
    {
        Print("[MAPVOTE] Debug mode is ON");
        wait 3;
        level notify("mapvote_vote_start");
    }
    else
    {
        // Starting the mapvote normally is handled in mp\mapvote_mp_extend.gsc
        //replaceFunc(maps\mp\gametypes\_killcam::finalkillcamwaiter, ::OnKillcamEnd);
    }
}

InitDvars()
{
    SetDvarIfNotInitialized("mapvote_debug", false);

    SetDvarIfNotInitialized("mapvote_maps", "Aftermath:Cargo:Carrier:Drone:Express:Hijacked:Meltdown:Overflow:Plaza:Raid:Slums:Standoff:Turbine:Yemen:Nuketown:Downhill:Mirage:Hydro:Grind:Encore:Magma:Vertigo:Studio:Uplink:Detour:Cove:Rush:Dig:Frost:Pod:Takeoff");
    SetDvarIfNotInitialized("mapvote_modes", "Team Deathmatch;tdm:Domination;dom:Hardpoint;koth");
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
}

InitVariables()
{
    SetMapvoteData("map");
    SetMapvoteData("mode");
    level.mapvote["vote_time"] = GetDvarInt("mapvote_vote_time");

    level.mapvote["colors"]["unselected"] = GetGscColor(GetDvar("mapvote_colors_unselected"));
    level.mapvote["colors"]["selected"] = GetGscColor(GetDvar("mapvote_colors_selected"));
    level.mapvote["colors"]["timer"] = GetGscColor(GetDvar("mapvote_colors_timer"));
    level.mapvote["colors"]["timer_low"] = GetGscColor(GetDvar("mapvote_colors_timer_low"));
    level.mapvote["colors"]["help_text"] = GetChatColor(GetDvar("mapvote_colors_help_text"));
    level.mapvote["colors"]["help_accent"] = GetChatColor(GetDvar("mapvote_colors_help_accent"));
    level.mapvote["colors"]["help_accent_mode"] = GetDvar("mapvote_colors_help_accent_mode");

    level.mapvote["blur_level"] = GetDvarInt("mapvote_blur_level");
    level.mapvote["blur_fade_in_time"] = GetDvarInt("mapvote_blur_fade_in_time");
    level.mapvote["horizontal_spacing"] = GetDvarInt("mapvote_horizontal_spacing");

    level.mapvote["vote"]["maps"] = [];
    level.mapvote["vote"]["modes"] = [];
    level.mapvote["hud"]["maps"] = [];
    level.mapvote["hud"]["modes"] = [];
}



/* Player section */

/*
This is used instead of notifyonplayercommand("mapvote_up", "speed_throw") 
to fix an issue where players using toggle ads would have to press right click twice for it to register one right click.
With this instead it keeps scrolling every 0.35s until they right click again which is a better user experience
*/
ListenForRightClick()
{
    self endon("disconnect");

    while (true)
    {
        if (self AdsButtonPressed())
        {
            self notify("mapvote_up");
            wait 0.35;
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

        if (input == "mapvote_down")
        {
            if (self.mapvote[section]["hovered_index"] < (level.mapvote[section + "s"]["by_index"].size - 1))
            {
                self playlocalsound("uin_start_count_down");
                self UpdateSelection(section, (self.mapvote[section]["hovered_index"] + 1));
            }
        }
        else if (input == "mapvote_up")
        {
            if (self.mapvote[section]["hovered_index"] > 0)
            {
                self playlocalsound("uin_start_count_down");
                self UpdateSelection(section, (self.mapvote[section]["hovered_index"] - 1));
            }
        }
        else if (input == "mapvote_select")
        {
            self playlocalsound("mpl_killconfirm_tags_pickup");
            self ConfirmSelection(section);
        }
        else if (input == "mapvote_unselect")
        {
            if (section != "map")
            {
                self playlocalsound("fly_betty_jump");
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
                    Print(player.name + " voted for map [" + player.mapvote["map"]["selected_index"] +"] " + level.mapvote["maps"]["by_index"][player.mapvote["map"]["selected_index"]]);
                }

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

        wait 0.05;
    }
}



/* Vote section */

CreateVoteMenu()
{
    //level endon("game_ended");

    spacing = 20;
    hudLastPosY = -(((level.mapvote["maps"]["by_index"].size + level.mapvote["modes"]["by_index"].size + 1) * spacing) / 2);
    //hudLastPosY = -100;

    for (mapIndex = 0; mapIndex < level.mapvote["maps"]["by_index"].size; mapIndex++)
    {
        mapVotesHud = CreateHudText("", "objective", 1.5, "LEFT", "CENTER", level.mapvote["horizontal_spacing"], hudLastPosY, true, 0);
        mapVotesHud.color = level.mapvote["colors"]["selected"];

        level.mapvote["hud"]["maps"][mapIndex] = mapVotesHud;

        foreach (player in GetHumanPlayers())
        {
            player.mapvote["map"][mapIndex]["hud"] = player CreateHudText(level.mapvote["maps"]["by_index"][mapIndex], "objective", 1.5, "LEFT", "CENTER", -level.mapvote["horizontal_spacing"], hudLastPosY);

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

    hudLastPosY += spacing; // Space between maps and modes sections

    for (modeIndex = 0; modeIndex < level.mapvote["modes"]["by_index"].size; modeIndex++)
    {
        modeVotesHud = CreateHudText("", "objective", 1.5, "LEFT", "CENTER", level.mapvote["horizontal_spacing"], hudLastPosY, true, 0);
        modeVotesHud.color = level.mapvote["colors"]["selected"];

        level.mapvote["hud"]["modes"][modeIndex] = modeVotesHud;

        foreach (player in GetHumanPlayers())
        {
            player.mapvote["mode"][modeIndex]["hud"] = player CreateHudText(level.mapvote["modes"]["by_index"][modeIndex], "objective", 1.5, "LEFT", "CENTER", -level.mapvote["horizontal_spacing"], hudLastPosY);

            SetElementUnselected(player.mapvote["mode"][modeIndex]["hud"]);
        }

        hudLastPosY += spacing;
    }

    foreach(player in GetHumanPlayers())
    {
        player.mapvote["map"]["selected_index"] = -1;
        player.mapvote["mode"]["selected_index"] = -1;

        buttonsHelpMessage = "";

        if (level.mapvote["colors"]["help_accent_mode"] == "standard")
        {
            buttonsHelpMessage = level.mapvote["colors"]["help_text"] + "Press " + level.mapvote["colors"]["help_accent"] + "[{+attack}] " + level.mapvote["colors"]["help_text"] + "to go down - Press " + level.mapvote["colors"]["help_accent"] + "[{+speed_throw}] " + level.mapvote["colors"]["help_text"] + "to go up - Press " + level.mapvote["colors"]["help_accent"] + "[{+gostand}] " + level.mapvote["colors"]["help_text"] + "to select - Press " + level.mapvote["colors"]["help_accent"] + "[{+activate}] " + level.mapvote["colors"]["help_text"] + "to undo";
        }
        else if(level.mapvote["colors"]["help_accent_mode"] == "max")
        {
            buttonsHelpMessage = level.mapvote["colors"]["help_text"] + "Press " + level.mapvote["colors"]["help_accent"] + "[{+attack}] " + level.mapvote["colors"]["help_text"] + "to go " + level.mapvote["colors"]["help_accent"] + "down " + level.mapvote["colors"]["help_text"] + "- Press " + level.mapvote["colors"]["help_accent"] + "[{+speed_throw}] " + level.mapvote["colors"]["help_text"] + "to go " + level.mapvote["colors"]["help_accent"] + "up " + level.mapvote["colors"]["help_text"] + "- Press " + level.mapvote["colors"]["help_accent"] + "[{+gostand}] " + level.mapvote["colors"]["help_text"] + "to " + level.mapvote["colors"]["help_accent"] + "select " + level.mapvote["colors"]["help_text"] + "- Press " + level.mapvote["colors"]["help_accent"] + "[{+activate}] " + level.mapvote["colors"]["help_text"] + "to " + level.mapvote["colors"]["help_accent"] + "undo";
        }

        if (GetDvarInt("mapvote_debug"))
        {
            if (level.mapvote["colors"]["help_accent_mode"] == "standard")
            {
                buttonsHelpMessage = buttonsHelpMessage + " - Press " + level.mapvote["colors"]["help_accent"] + "[{+melee}] " + level.mapvote["colors"]["help_text"] + "to debug";
            }
            else if(level.mapvote["colors"]["help_accent_mode"] == "max")
            {
                buttonsHelpMessage = buttonsHelpMessage + level.mapvote["colors"]["help_text"] + " - Press " + level.mapvote["colors"]["help_accent"] + "[{+melee}] " + level.mapvote["colors"]["help_text"] + "to " + level.mapvote["colors"]["help_accent"] + "debug";
            }
        }

        player CreateHudText(buttonsHelpMessage, "objective", 1.5, "CENTER", "CENTER", 0, 210); 
    }
}

CreateVoteTimer()
{
	soundFX = spawn("script_origin", (0,0,0));
	soundFX hide();
	
	timerhud = CreateTimer(level.mapvote["vote_time"], &"Vote ends in: ", "objective", 1.5, "CENTER", "CENTER", 0, -210);		
    timerhud.color = level.mapvote["colors"]["timer"];
	for (i = level.mapvote["vote_time"]; i > 0; i--)
	{	
		if(i <= 5) 
		{
			timerhud.color = level.mapvote["colors"]["timer_low"];
			soundFX playSound( "mpl_ui_timer_countdown" );
		}
		wait(1);
	}	
	level notify("mapvote_vote_end");
}

ListenForStartVote()
{
    level endon("end_game");
    level waittill("mapvote_vote_start");

    for (i = 0; i < level.mapvote["maps"]["by_index"].size; i++)
    {
        level.mapvote["vote"]["maps"][i] = 0;
    }

    for (i = 0; i < level.mapvote["modes"]["by_index"].size; i++)
    {
        level.mapvote["vote"]["modes"][i] = 0;
    }

    level thread CreateVoteMenu();
    level thread CreateVoteTimer();

    foreach (player in GetHumanPlayers())
    {
        player FreezeControlsAllowLook(1);
        player SetBlur(level.mapvote["blur_level"], level.mapvote["blur_fade_in_time"]);

        player thread ListenForVoteInputs();
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

    if (mostVotedModeVotes == 0)
    {
        mostVotedModeIndex = GetRandomElementInArray(GetArrayKeys(level.mapvote["vote"]["modes"]));

        if (GetDvarInt("mapvote_debug"))
        {
            Print("[MAPVOTE] No vote for mode. Chosen random mode index: " + mostVotedModeIndex);
        }
    }

    modeName = level.mapvote["modes"]["by_index"][mostVotedModeIndex];
    modeCfg = level.mapvote["modes"]["by_name"][level.mapvote["modes"]["by_index"][mostVotedModeIndex]];
    mapName = GetMapCodeName(level.mapvote["maps"]["by_index"][mostVotedMapIndex]);
    
    if (GetDvarInt("mapvote_debug"))
    {
        Print("[MAPVOTE] Rotating to " + mapName + " | " + modeName + " (" + modeCfg + ".cfg)");
    }

    setdvar("sv_maprotationcurrent", "exec " + modeCfg + ".cfg map " + mapName);
	setdvar("sv_maprotation", "exec " + modeCfg + ".cfg map " + mapName);
}

SetMapvoteData(type)
{
    limit = 0;

    availableElements = StrTok(GetDvar("mapvote_" + type + "s"), ":");

    if (type == "map")
    {
        if (availableElements.size < 6)
        {
            limit = availableElements.size;
        }
        else
        {
            limit = 6;
        }

        level.mapvote["maps"]["by_index"] = GetRandomUniqueElementsInArray(availableElements, limit);
    }
    else if (type == "mode")
    {
        if (availableElements.size < 4)
        {
            limit = availableElements.size;
        }
        else
        {
            limit = 4;
        }

        finalElements = [];

        foreach (mode in GetRandomUniqueElementsInArray(availableElements, limit))
        {
            splittedMode = StrTok(mode, ";");
            finalElements = AddElementToArray(finalElements, splittedMode[0]);

            level.mapvote["modes"]["by_name"][splittedMode[0]] = splittedMode[1];
        }

        level.mapvote["modes"]["by_index"] = finalElements;
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
    element.color = level.mapvote["colors"]["selected"];
}

SetElementUnselected(element)
{
    element.color = level.mapvote["colors"]["unselected"];
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

GetHumanPlayers()
{
    humanPlayers = [];

    foreach (player in level.players)
    {
        if (!player IsBot())
        {
            humanPlayers[humanPlayers.size] = player;
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
    switch(mapName)
    {
        case "Nuketown":
        return "mp_nuketown_2020";

        case "Hijacked":
        return "mp_hijacked";

        case "Meltdown":
        return "mp_meltdown";

        case "Express":
        return "mp_express";

        case "Carrier":
        return "mp_carrier";

        case "Overflow":
        return "mp_overflow";

        case "Slums":
        return "mp_slums";

        case "Aftermath":
        return "mp_la";

        case "Cargo":
        return "mp_dockside";

        case "Turbine":
        return "mp_turbine";

        case "Drone":
        return "mp_drone";

        case "Raid":
        return "mp_raid";

        case "Standoff":
        return "mp_village";

        case "Plaza":
        return "mp_nightclub";

        case "Yemen":
        return "mp_socotra";

        case "Uplink":
        return "mp_uplink";

        case "Detour":
        return "mp_bridge";

        case "Cove":
        return "mp_castaway";

        case "Rush":
        return "mp_paintball";

        case "Studio":
        return "mp_studio";

        case "Magma":
        return "mp_magma";

        case "Vertigo":
        return "mp_vertigo";

        case "Encore":
        return "mp_concert";

        case "Downhill":
        return "mp_downhill";

        case "Grind":
        return "mp_skate";

        case "Hydro":
        return "mp_hydro";

        case "Mirage":
        return "mp_mirage";

        case "Frost":
        return "mp_frostbite";

        case "Takeoff":
        return "mp_takeoff";

        case "Pod":
        return "mp_pod";

        case "Dig":
        return "mp_dig"; 
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
# Mapvote

A customizable mapvote script for multiplayer.  
Zombies is not supported yet but is planned for the future.

Also note that this only works for dedicated servers.  
You can still run the script in a private match to get a preview of the colors and everything but it won't rotate to your chosen map/mode due a technical limitation.  

This is heavily inspired by [LastDemon99's IW5 mapvote](https://github.com/LastDemon99/IW5_VoteSystem).  
I also re-used some code from [DoktorSAS T6 mapvote](https://github.com/DoktorSAS/PlutoniumT6Mapvote).  
Huge thanks to both of them.

![mapvote1](https://raw.githubusercontent.com/Resxt/Plutonium-T6-Scripts/main/mapvote/images/mapvote1.png)
*Mouse and keyboard input. Settings: default*

![mapvote2](https://raw.githubusercontent.com/Resxt/Plutonium-T6-Scripts/main/mapvote/images/mapvote2.png)
*Controller input. Settings: red colors, blur level: 5, horizontal spacing: 100, accent mode: max*

## mapvote.gsc

This script can either be installed in the `scripts` folder or in the `scripts\mp` folder.  
**IMPORTANT** Installing `mapvote_mp_extend.gsc` in `scripts\mp` is **mandatory** to make the mapvote work normally.

### Main features

- It allows up to 6 maps and 4 modes to be displayed at once
- It has separate map and mode choices
- It supports custom gamemode names and custom cfg
- It rotates a random map from the list when there are no votes for maps. Same applies for modes
- Controllers are fully supported and work out of the box
- It has a good level of customization
- It has a debug mode to quickly preview the menu

### Getting started

By default the script is disabled to avoid running on all your servers.  
Simply set `mapvote_enable` to 1 and the script will be loaded, which as a result will display the voting menu after the killcam.  

To configure the menu before putting it on your server I recommend running it in a custom game with the `mapvote_debug` dvar set to `1`.  
To do that use this command in the console `set mapvote_enable 1;set mapvote_debug 1` before running a custom game.  
Start a custom game and pick any class and you will see the menu. Everything will work but map rotation which is normal.  
You can then configure the dvars directly in your console and restart the map with `map_restart` in the console to edit the menu quickly and get your perfect setup.

### Dvars

Here are the dvars you can configure:

| Name | Description | Default value | Accepted values |
|---|---|---|---|
| mapvote_enable | Toggle whether the mapvote is activated or not. 0 is off and 1 is on | 0 | 0 or 1 |
| mapvote_debug | Toggle whether the mapvote runs in debug mode or not. This will display the mapvote menu a few seconds after starting the game. 0 is off and 1 is on | 0 | 0 or 1 |
| mapvote_maps | A list of the maps that are available for rotation. Each map name needs to start with a capitalized letter and each map is separated with : | Every BO2 maps including DLC maps | Any map name, starting with a capitalized letter and separated with a colon (:) |
| mapvote_modes | A list of the modes that are available for rotation. The first parameter is how the mode will be displayed, it can be set to anything you like, the second parameter is the name of the cfg file to load found in the gamesettings folder | "Team Deathmatch,tdm:Domination,dom:Hardpoint,koth" | Any name you want followed by a comma (,) with the cfg name and separated with a colon (:) |
| mapvote_colors_selected | The color of the text when hovered or selected. This is also the color of the votes count | "blue" | red, green, yellow, blue, cyan, purple, white, grey, gray, black |
| mapvote_colors_unselected | The color of the text when not hovered and not selected | "white" | red, green, yellow, blue, cyan, purple, white, grey, gray, black |
| mapvote_colors_timer | The color of the timer as long as it has more than 5 seconds remaining | "blue" | red, green, yellow, blue, cyan, purple, white, grey, gray, black |
| mapvote_colors_timer_low | The color of the timer when it has 5 or less seconds remaining | "red" | red, green, yellow, blue, cyan, purple, white, grey, gray, black |
| mapvote_colors_help_text | The color of the help text at the bottom explaining how to use the menu | "white" | red, green, yellow, blue, cyan, purple, white, grey, gray, black |
| mapvote_colors_help_accent | The color of the accented text of the help text at the bottom | "blue" | red, green, yellow, blue, cyan, purple, white, grey, gray, black |
| mapvote_colors_help_accent_mode | The accenting mode for the help text. `standard` only puts the accent color on the button to press and `max` puts it on both the buttons and the action it does | "standard" | standard or max |
| mapvote_sounds_menu_enabled | Toggle whether the mapvote menu sounds are enabled or not. 0 is off and 1 is on | 1 | 0 or 1 |
| mapvote_sounds_timer_enabled | Toggle whether the timer will start making a beeping sound every second when there's 5 or less seconds remaining to vote or not. 0 is off and 1 is on | 1 | 0 or 1 |
| mapvote_vote_time | The time the vote lasts (in seconds) | 30 | Any plain number above 5 |
| mapvote_blur_level | The amount of blur to put at the end of the killcam. The max recommended value is 5. 0 disables it | 2.5 | Any number |
| mapvote_blur_fade_in_time | The time (in seconds) it takes for the blur to reach `mapvote_blur_level`. For example if you set it to 10 and `mapvote_blur_level` is 5 then it will progressively blur the screen from 0 to 5 in 10 seconds | 2 | Any number |
| mapvote_horizontal_spacing | The horizontal spacing between the map/mode names on the left and the vote counts on the right. I recommend setting this value according to your map and modes length so that it doesn't overlap with the vote counts | 75 | Any plain number |
| mapvote_display_wait_time | Once the killcam ends, the time to wait before displaying the vote menu after the killcam ends (in seconds) | 1 | 0.05 or above |

### Configuration

Below is an example CFG showing how each dvars can be configured.  
The values you see are the default values that will be used if you don't set a dvar.  

```c
set mapvote_enable 1
set mapvote_maps "Aftermath:Cargo:Carrier:Drone:Express:Hijacked:Meltdown:Overflow:Plaza:Raid:Slums:Standoff:Turbine:Yemen:Nuketown:Downhill:Mirage:Hydro:Grind:Encore:Magma:Vertigo:Studio:Uplink:Detour:Cove:Rush:Dig:Frost:Pod:Takeoff"
set mapvote_modes "Team Deathmatch,tdm:Domination,dom:Hardpoint,koth"
set mapvote_colors_selected "blue"
set mapvote_colors_unselected "white"
set mapvote_colors_timer "blue"
set mapvote_colors_timer_low "red"
set mapvote_colors_help_text "white"
set mapvote_colors_help_accent "blue"
set mapvote_colors_help_accent_mode "standard"
set mapvote_sounds_menu_enabled 1
set mapvote_sounds_timer_enabled 1
set mapvote_vote_time 30
set mapvote_blur_level 2.5
set mapvote_blur_fade_in_time 2
set mapvote_horizontal_spacing 75
set mapvote_display_wait_time 1
```

Here are some pre-set values if you want to quickly copy/paste something

| Description | Value |
|---|---|
| All base game maps | "Aftermath:Cargo:Carrier:Drone:Express:Hijacked:Meltdown:Overflow:Plaza:Raid:Slums:Standoff:Turbine:Yemen" |
| All DLC maps | "Nuketown:Downhill:Mirage:Hydro:Grind:Encore:Magma:Vertigo:Studio:Uplink:Detour:Cove:Rush:Dig:Frost:Pod:Takeoff" |
| Classic modes | "Team Deathmatch,tdm:Domination,dom:Hardpoint,koth" |
| Objective modes | "Demolition,dem:Headquaters,hq:Capture the Flag,ctf" |
| Alternative modes | "Kill Confirmed,conf:One Flag CTF,oneflag" |
| Party modes | "Gun Game,gun:One in the Chamber,oic:Sharpshooter,shrp:Sticks & Stones,sas" |
| FFA 24/7 | "Free for All,dm" |
| SND 24/7 | "Search & Destroy,sd" |

### Notes

- If right click is set to toggle ads then pressing right click will make the player go up by one every 0.35s.  
If I didn't change it to be that way players with toggle ads would have to press right click twice to go up by one all the time.  
Now instead they simply right click once to start going up and right click again to stop.
- When two maps/modes have the same votes, the lowest one in the list will win. In the future it would be nice to randomize between both
- Ending the game with ESC doesn't work when in debug mode.  
Use `map_restart` in the console when your script is compiled. And if you want to leave use `disconnect` in the console until this is fixed  
- When there's only one map/mode the right map/mode will be chosen but adding an option to hide single vote elements would be nice

## mapvote_mp_extend.gsc

A small script that goes with `mapvote.gsc` to make it work in multiplayer.  
It has to be installed in the `mp` directory since it contains multiplayer only code.  
Putting it in `scripts` or `scripts\zm` will throw an error when booting up a zombies map.

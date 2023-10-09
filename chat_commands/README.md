# Chat commands

Let players execute commands by typing in the chat.  
This can be used to display text to the player, for example the server rules or execute GSC code, just like console commands.  
This works in private games, on dedicated servers that use [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin) and those that don't.  
If you do monitor your server with [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin) then make sure to read the [notes section](#notes).  

The `chat_command` scripts you find here work for both MP and ZM and can be placed in the `scripts` folder.  
MP only scripts are in the [mp](mp) folder and ZM only scripts are in the [zm](zm) folder.

## chat_commands.gsc

The core script that holds the configuration, runs all the chat logic and holds utils function that are shared between all the `chat_command` scripts.  

**[IMPORTANT]** Installing `chat_commands.gsc` is **mandatory** to make the commands work as this is the core of this whole system and all the command scripts depend on it.  
**[IMPORTANT]** By default `chat_commands.gsc` is made to be placed in the `scripts` folder.  
If you place it in the `scripts\mp` or `scripts\zm` folder instead then you will need to update the include of each command script accordingly (first line) or you will get errors.  
You simply have to replace `#include scripts\chat_commands` with `#include scripts\mp\chat_commands;` or `#include scripts\zm\chat_commands;` in each of your command script.

Also note that `chat_commands.gsc` doesn't provide any command on its own.  
You must install at least one command script to be able to use commands. Otherwise it will always say that you don't have any command.

### Main features

- Easy per server (port) commands configuration. You can either pass an array of one server port, or multiple, or the `level.chat_commands["ports"]` array to easily add a command to one/multiple/all servers
- Chat text print and functions support
- Optional permissions level system to restrict commands to players with a certain permission level (disabled by default)
- All exceptions are handled with error messages (no commands on the server, not enough arguments, command doesn't exist, command doesn't have any help message, player doesn't exist etc.)
- A `commands` command that lists all available commands on the server you're on dynamically (only lists commands you have access to if the permission system is enabled)
- A `help` command that explains how to use a given command. For example `help map` (only works on commands you have access to if the permission system is enabled)
- `alias` and `aliases` commands that list the available aliases for a command. For example `alias godmode` (only works on commands you have access to if the permission system is enabled)
- All commands that require a target work with `me`. Also it doesn't matter how you type the player's name as long as you type his full name or type the beginning of his username (has to be unique, see [#3](https://github.com/Resxt/Plutonium-IW5-Scripts/pull/3/commits/2efa784709b5c42811510c67c3e6a2fc5eb3fc70)).
- Configurable command prefix. Set to `!` by default
- A plugin system to easily allow adding/removing commands. Each command has its own GSC file to easily add/remove/review/configure your commands. This also makes contributing by creating a PR to add a command a lot easier

### Dvars

Here are the dvars you can configure:
  
| Name | Description | Default value | Accepted values |
|---|---|---|---|
| cc_debug | Toggle whether the script is in debug mode or not. This is used to print players GUID in the console when they connect | 0 | 0 or 1 |
| cc_prefix | The symbol to type before the command name in the chat. Only one character is supported. The `/` symbol won't work normally as it's reserved by the game. If you use the `/` symbol as prefix you will need to type double slash in the game | ! | Any working symbol |
| cc_permission_enabled | Toggle whether the permission system is enabled or not. If it's disabled any player can run any available command | 0 | 0 or 1 |
| cc_permission_mode | Changes whether the permission dvars values are names or guids | name | name or guid |
| cc_permission_default | The default permission level players who aren't found in the permission dvars will be granted | 1 | Any plain number from 0 to `cc_permission_max` |
| cc_permission_max | The maximum/most elevated permission level | 4 | Any plain number above 0 |
| cc_permission_0 | A list of names or guids of players who will be granted the permission level 0 when connecting (no access to any command) | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |
| cc_permission_1 | A list of names or guids of players who will be granted the permission level 1 when connecting  | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |
| cc_permission_2 | A list of names or guids of players who will be granted the permission level 2 when connecting  | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |
| cc_permission_3 | A list of names or guids of players who will be granted the permission level 3 when connecting  | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |
| cc_permission_4 | A list of names or guids of players who will be granted the permission level 4 when connecting  | "" | Names or guids (depending on `cc_permission_mode`). Each value is separated with a colon (:) |

### Configuration

Below is an example CFG showing how each dvars can be configured.  
The values you see are the default values that will be used if you don't set a dvar.  

```c
set cc_debug 0
set cc_prefix "!"
set cc_permission_enabled 0
set cc_permission_mode "name"
set cc_permission_default 1
set cc_permission_max 4
set cc_permission_0 ""
set cc_permission_1 ""
set cc_permission_2 ""
set cc_permission_3 ""
set cc_permission_4 ""
```

### Notes

- To pass an argument with a space you need to put `'` around it. For example if a player name is `The Moonlight` then you would write `!teleport 'The Moonlight' Resxt`
- If you use [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin) make sure you have a different commands prefix to avoid conflicts. For example `!` for IW4MAdmin commands and `.` for this script. The commands prefix can be modified by changing the value of the `cc_prefix` dvar. As for [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin), at the time of writing, if you want to change it you'll need to change the value of [CommandPrefix](https://github.com/RaidMax/IW4M-Admin/wiki/Configuration#advanced-configuration)
- If you prefer to display information (error messages, status change etc.) in the player's chat rather than on his screen you can do that on a dedicated server. For this you need to install [t6-gsc-utils.dll](https://github.com/fedddddd/t6-gsc-utils#installation) (dedicated server only) and change `self IPrintLnBold(message);` to `self tell(message);` in the `TellPlayer` function
- Support for clantags was added. You can use the player names in-game or in the dvars without having to care about their clantag. The [setClantag function](https://github.com/fedddddd/t6-gsc-utils#chat) replaces the player name so additional work was required to make the script ignore the clantag

## chat_command_dvars.gsc

3 related commands in one file:  

- Print server dvar
- Change server dvar
- Change client dvar

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| getdvar | Prints the (server) dvar value in the player's chat | (1) the dvar name | `!getdvar g_speed` | 2 |
| setdvar | Changes a dvar on the server | (1) the dvar name (2) the new dvar value | `!setdvar jump_height 500` | 4 |
| setclientdvar | Changes a dvar on the targeted player | (1) the name of the player (2) the dvar name (3) the new dvar value | `!setclientdvar Resxt cg_thirdperson 1` | 4 |

## chat_command_freeze.gsc

Toggles whether the targeted player can move or not.  
Note that this does not work during the prematch period.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to freeze/unfreeze | :white_check_mark: |

| Examples |
|---|
| `!freeze me` |
| `!freeze Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_give.gsc

<!-- 2 related commands in one file: -->

- Give weapon (with or without attachment(s) and camo in MP)

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| giveweapon | Gives the targeted player the specific weapon. Attachments and camo can be passed | (1) the name of the player (2) the weapon codename (3) optional, camo index from 0 to 45 | `!giveweapon me tar21_mp` | 2 |

You can use [chat_command_info.gsc](#chat_command_infogsc) to list available weapons and their attachments.  
Alternatively you can use [this](https://forum.plutonium.pw/topic/1909/resource-stat-modification-checks-other-structures) to get weapon/attachment names from your browser.

| More examples (MP) | Description |
|---|---|
| `!giveweapon me kard_mp` | Give weapon by codename |
| `!giveweapon me an94` | Give weapon by codename without `_mp` at the end |
| `!giveweapon me ballista_mp 15` | Give weapon by codename with camo index 15, in this case the Gold camo |
| `!giveweapon me as50_mp+ir` | Give weapon by codename with an attachment |
| `!giveweapon me dsr50_mp+silencer 16` | Give weapon by codename with an attachment and camo index 16, in this case the Diamond camo |
| `!giveweapon me ballista+is+silencer 12` | Give weapon by codename without `_mp` at the end, with 2 attachments and with camo index 12, in this case the Art of War camo |
| `!giveweapon me tar21+silencer+reflex+fastads 11` | Give weapon by codename with 3 attachments and camo index 11, in this case the Cherry Blossom camo |

| More examples (ZM) |
|---|
| `!giveweapon me m14_zm` (give weapon by codename) |
| `!giveweapon me m1911_upgraded_zm` (give upgraded/PAPed weapon by codename) |

## chat_command_god_mode.gsc

Toggles whether the targeted player is in god mode (invincible) or not.  

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle god mode for | :white_check_mark: |

| Examples |
|---|
| `!god me` |
| `!god Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_info.gsc

2 related commands in one file:  

- List available weapons
- List available attachments (MP only)

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| listweapons | Prints all the available weapons. No argument prints code names, any argument will print display/human readable names instead | (1) optional, any text | `!listweapons` | 2 |
| listattachments | Prints all the available attachments for that weapon. No argument prints available attachments for the weapon you're holding, a valid weapon codename as argument will print this weapon's available attachments instead | (1) optional, valid weapon codename | `!listattachments dsr50_mp` | 2 |

You can check [this](https://forum.plutonium.pw/topic/1909/resource-stat-modification-checks-other-structures) to get weapon/attachment names from your browser instead.

| More examples |
|---|
| `!listweapons` |
| `!listweapons display` |
| `!listattachments` |
| `!listattachments tar21_mp` |
| `!listattachments dsr50` |

## chat_command_invisible.gsc

Toggles invisibility on the targeted player.  
Note that this does not make the player invisible to bots in multiplayer, in the sense that even if they can't see the player, they will still know his position and shoot him.  
However, in addition to being invisible, you will also be ignored by zombies in the zombies mode.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to make invisible/visible | :white_check_mark: |

| Examples |
|---|
| `!invisible me` |
| `!invisible Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_kick.gsc

Kicks the targeted player.  
Note that due to some game limitations you cannot kick the host.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to kick | :white_check_mark: |

| Examples |
|---|
| `!kick Resxt` |

| Permission level |
|---|
| 4 |

## chat_command_permissions.gsc

2 related commands in one file:  

- Get permission level
- Set permission level

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| getpermission | Prints the targeted player's current permission level in the player's chat | (1) the name of the targeted player | `!getpermission me` | 2 |
| setpermission | Changes the targeted player's permission level (for the current game only) | (1) the name of the targeted player (2) the permission level to grant | `!setpermission Resxt 4` | 4 |

## chat_command_teleport.gsc

Teleports a player to the position of another player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to teleport | :white_check_mark: |
| 2 | The name of the player to teleport to | :white_check_mark: |

| Examples |
|---|
| `!teleport me Eldor` |
| `!teleport Eldor me` |
| `!teleport Eldor Rektinator` |

| Permission level |
|---|
| 2 |

## chat_command_text_help.gsc

Prints how to use the `commands` and the `help command` commands in the player's chat.

| Example |
|---|
| `!help` |

| Permission level |
|---|
| 1 |

## chat_command_ufo_mode.gsc

Toggles whether the targeted player can use the ufo mode or not.  
This allows the player to fly around the map by holding the melee button and, if death barrier protection is on, to get out of map without dying.  

The death barrier protection is on by default.  
In ZM it will remove the death barriers for the entire team.  
In MP it will put the player in god mode until disabling UFO mode (running the command again).  
If the player had god mode from the god mode chat command he will keep the god mode.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle ufo mode for | :white_check_mark: |

| Examples |
|---|
| `!ufomode me` |
| `!ufomode Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_unfair_aimbot.gsc

Toggles unfair aimbot on the targeted player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle unfair aimbot for | :white_check_mark: |

| Examples |
|---|
| `!unfairaimbot me` |
| `!unfairaimbot Resxt` |

| Permission level |
|---|
| 4 |

## chat_command_unlimited_ammo.gsc

Toggles unlimited ammo on the targeted player.

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle unlimited ammo for | :white_check_mark: |

| Examples |
|---|
| `!unlimitedammo me` |
| `!unlimitedammo Resxt` |

| Permission level |
|---|
| 3 |

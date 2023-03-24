# Chat commands

Let players execute commands by typing in the chat.  
This can be used to display text to the player, for example the server rules or execute GSC code, just like console commands.  
This works in private games, on dedicated servers that use [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin) and those that don't.  
If you do monitor your server with [IW4MAdmin](https://github.com/RaidMax/IW4M-Admin) then make sure to read the [notes section](#notes).  

The `chat_command` scripts you find here work for both MP and ZM and can be placed in the `scripts` folder.  
MP only scripts are in the [mp](mp) folder and ZM only scripts are in the [zm](zm) folder.

## chat_commands.gsc

The core script that holds the configuration, runs all the chat logic and holds utils function that are shared between all the `chat_command` scripts.  
**[IMPORTANT]** Installing it is **mandatory** to make the commands work as this is the core of this whole system and all the command scripts depend on it.  
Also note that this script doesn't provide any command on its own. You must install at least one command script to be able to use commands. Otherwise it will always say that you don't have any command.

### Main features

- Easy per server (port) commands configuration. You can either pass an array of one server port, or multiple, or the `level.chat_commands["ports"]` array to easily add a command to one/multiple/all servers
- Chat text print and functions support
- Optional permissions level system to restrict commands to players with a certain permission level (disabled by default)
- All exceptions are handled with error messages (no commands on the server, not enough arguments, command doesn't exist, command doesn't have any help message, player doesn't exist etc.)
- A `commands` command that lists all available commands on the server you're on dynamically (only lists commands you have access to if the permission system is enabled)
- A `help` command that explains how to use a given command. For example `help map` (only works on commands you have access to if the permission system is enabled)
- All commands that require a target work with `me`. Also it doesn't matter how you type the player's name as long as you type the full name.
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

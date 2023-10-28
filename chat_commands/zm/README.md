# ZM Chat commands

These scripts go in `scripts\zm`

## chat_command_give.gsc

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| givepowerup | Makes the powerup drop on the player, which activates it | (1) the code name of the powerup | `!givepowerup full_ammo` | 2 |
| giveperk | Gives the chosen perk to the targeted player  | (1) the name of the targeted player (2) the name of the perk (multiple aliases available, see the GetPerkInfos function in [chat_commands](../chat_commands.gsc)) | `!giveperk me jugg` | 2 |

You can use [chat_command_info.gsc](../README.md#chat_command_infogsc) to list available powerups and perks.  
Alternatively you can use [this](https://github.com/plutoniummod/t6-scripts/blob/main/ZM/Core/maps/mp/zombies/_zm_powerups.gsc#L95) to get powerup code names from your browser (first parameter of the `add_zombie_powerup` function calls). Note that this lists all powerups without taking into account whether they're available on the map you play on or not.  

You can disable the perk music and/or the bottle animation whenever you use `!giveperk` by changing the corresponding boolean(s) to false in the `GivePlayerPerk` function call.  

Note that like other scripts on this page this is a ZM only script, but this script also has a global version (works in both MP and ZM) that you can find [here](../chat_command_give.gsc) if you're looking for more give commands.  
You can have both installed at the same time as long as this script is in the `zm` folder and the global version is either in the `scripts` folder or the `mp` folder.

| More examples |
|---|
| `!givepowerup all` |
| `!givepowerup all_no_nuke` |
| `!giveperk me all` |
| `!giveperk me quickrevive` |

## chat_command_no_target.gsc

Toggles whether the targeted player is in no target mode (invisible to zombies) or not.  

| # | Argument | Mandatory |
|---|---|---|
| 1 | The name of the player to toggle no target for | :white_check_mark: |

| Examples |
|---|
| `!notarget me` |
| `!notarget Resxt` |

| Permission level |
|---|
| 3 |

## chat_command_points.gsc

4 related commands in one file:  

- Set points
- Add points
- Take/remove points
- Give/transfer points

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| setpoints | Changes how much points the targeted player has | (1) the name of the targeted player (2) the new amount of points to set | `!setpoints me 50000` | 3 |
| addpoints | Gives points to the targeted player | (1) the name of the targeted player (2) the amount of points to give | `!addpoints Resxt 2500` | 3 |
| takepoints | Takes/removes points from the targeted player | (1) the name of the targeted player (2) the amount of points to take from the player | `!takepoints Resxt 500` | 3 |
| givepoints | Gives/transfers points from the player running the command to the targeted player | (1) the name of the targeted player (2) the amount of points to give | `!givepoints Resxt 2500` | 2 |

## chat_command_rounds.gsc

4 related commands in one file:  

- Set round
- Change to previous round
- Change to next round
- Restart current round

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| setround | Kills all zombies and changes the round to the specified round | (1) the desired round number | `!setround 10` | 4 |
| previousround | Kills all zombies and changes the round to the previous round | none | `!previousround` | 4 |
| nextround | Kills all zombies and changes the round to the next round | none | `!nextround` | 4 |
| restartround | Kills all zombies and restarts the current round | none | `!restartround` | 4 |

It's recommend to only run these commands after at least one zombie has fully spawned (got out of the ground and starts walking).  
Your score and kills don't increase when running these commands even if you're technically the one who kills the zombies.

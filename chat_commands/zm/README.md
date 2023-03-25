# ZM Chat commands

These scripts go in `scripts\zm`

## chat_command_points.gsc

3 related commands in one file:  

- Set points
- Add points
- Take/remove points

| Name | Description | Arguments expected | Example | Permission level |
|---|---|---|---|---|
| setpoints | Changes how much points the targeted player has | (1) the name of the targeted player (2) the new amount of points to set | `!setpoints me 50000` | 3 |
| addpoints | Gives points to the targeted player | (1) the name of the targeted player (2) the amount of points to give | `!addpoints Resxt 2500` | 3 |
| takepoints | Takes/removes points from the targeted player | (1) the name of the targeted player (2) the amount of points to take from the player | `!takepoints Resxt 500` | 3 |

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

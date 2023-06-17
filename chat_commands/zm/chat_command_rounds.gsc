#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "setround", "function", ::SetRoundCommand, 4, [], array("sr"));
    CreateCommand(level.chat_commands["ports"], "previousround", "function", ::PreviousRoundCommand, 4, [], array("pr"));
    CreateCommand(level.chat_commands["ports"], "nextround", "function", ::NextRoundCommand, 4, [], array("nr"));
    CreateCommand(level.chat_commands["ports"], "restartround", "function", ::RestartRoundCommand, 4, [], array("rr"));
}



/* Command section */

SetRoundCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = SetRound(args[0], true);

    if (IsDefined(error))
    {
        return error;
    }

    TellAllPlayers(array("^5" + self.name + " ^7changed the round to round ^5" + args[0]));
}

PreviousRoundCommand(args)
{
    error = SetRound((level.round_number - 1), true);

    if (IsDefined(error))
    {
        return error;
    }

    TellAllPlayers(array("^5" + self.name + " ^7changed the round to the ^5previous round"));
}

NextRoundCommand(args)
{
    error = SetRound((level.round_number + 1), true);

    if (IsDefined(error))
    {
        return error;
    }
    
    TellAllPlayers(array("^5" + self.name + " ^7changed the round to the ^5next round"));
}

RestartRoundCommand(args)
{
    error = SetRound((level.round_number), false);

    if (IsDefined(error))
    {
        return error;
    }

    TellAllPlayers(array("^5" + self.name + " ^7restarted the ^5current ^7round"));
}



/* Logic section */

SetRound(roundNumber, doNukeEffect)
{
    roundNumber = int(roundNumber);

    if (roundNumber <= 0)
    {
        return InvalidRoundError(roundNumber);
    }

    self thread KillAllZombies(doNukeEffect);

    if (level.round_number > 1 || roundNumber > 1 || level.round_number == roundNumber)
    {
        level.round_number = roundNumber - 1;
    }
}

KillAllZombies(doNukeEffect)
{
    zombies = GetAIArray("axis");

    level.zombie_total = 0;
    playerScore = self.score;
    playerKills = self.kills;

    if(IsDefined(zombies))
    {
        for(i=0; i < zombies.size; i++)
        {
            zombies[i] DoDamage(zombies[i].health * 5000, (0,0,0), self);

            wait 0.05;
        }

        if (IsDefined(doNukeEffect) && doNukeEffect)
        {
            self DoNuke();
        }
    }

    self.score = playerScore; // reset the player's score to the score he had before calling the command
    self.kills = playerKills; // reset the player's kills to the kills he had before calling the command
}

DoNuke()
{
    foreach(player in level.players)
    {
        level thread maps\mp\zombies\_zm_powerups::nuke_powerup(self, player.team);
        player maps\mp\zombies\_zm_powerups::powerup_vo("nuke");

        zombies = getaiarray(level.zombie_team);

        player.zombie_nuked = arraysort(zombies, self.origin);

        player notify("nuke_triggered");
    }
}
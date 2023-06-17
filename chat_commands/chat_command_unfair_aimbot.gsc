#include scripts\chat_commands;

Init()
{
    CreateCommand(level.chat_commands["ports"], "unfairaimbot", "function", ::UnfairAimbotCommand, 4, array("default_help_one_player"), array("aimbot"));
}



/* Command section */

UnfairAimbotCommand(args)
{
    if (args.size < 1)
    {
        return NotEnoughArgsError(1);
    }

    error = ToggleUnfairAimbot(args[0]);

    if (IsDefined(error))
    {
        return error;
    }
}



/* Logic section */

ToggleUnfairAimbot(playerName)
{
    player = FindPlayerByName(playerName);

    if (!IsDefined(player))
    {
        return PlayerDoesNotExistError(playerName);
    }

    commandName = "unfairaimbot";

    ToggleStatus(commandName, "Unfair Aimbot", player);

    if (GetStatus(commandName, player))
    {
        player thread DoUnfairAimbot(true);
        player thread ThreadUnfairAimbot();
    }
    else
    {
        player notify("chat_commands_unfair_aimbot_off");
    }
}

ThreadUnfairAimbot()
{
    self endon("disconnect");
    self endon("chat_commands_unfair_aimbot_off");
    
    for(;;)
    {
        self waittill("spawned_player");

        self thread DoUnfairAimbot(true);
    }
}

DoUnfairAimbot(requiresAiming)
{
    self endon("death");
    self endon("disconnect");
    self endon("chat_commands_unfair_aimbot_off");

    targets = [];
    damageFunction = undefined;

    if (IsMultiplayerMode())
    {
        damageFunction = ::MultiplayerDamage;
    }
    else
    {
        damageFunction = ::ZombiesDamage;
    }

    while (true)
    {
        currentTarget = undefined;

        if (IsMultiplayerMode())
        {
            targets = level.players;
        }
        else
        {
            targets = getaiarray("axis");
        }

        foreach(potentialTarget in targets)
        {
            if((potentialTarget == self) || (level.teamBased && self.pers["team"] == potentialTarget.pers["team"]) || (!isAlive(potentialTarget))) // don't aim at yourself, allies and targets that aren't spawned
            {
                continue; // skip
            }
            
            if(IsDefined(currentTarget))
            {
                if(Closer( self getTagOrigin( "j_head" ), potentialTarget getTagOrigin( "j_head" ), currentTarget getTagOrigin( "j_head" )))
                {
                    currentTarget = potentialTarget;
                }
            }
            else
            {
                currentTarget = potentialTarget;
            }
        }

        if(IsDefined( currentTarget ))
        {
            if (!IsDefined(requiresAiming) || !requiresAiming || requiresAiming && self AdsButtonPressed())
            {
                self SetPlayerAngles(VectorToAngles(( currentTarget getTagOrigin( "j_head" )) - (self getTagOrigin( "j_head" ))));

                if(self AttackButtonPressed())
                {
                    currentTarget thread [[damageFunction]](self);
                }
            }
        }

        wait 0.05;
    }
}

MultiplayerDamage(attackingPlayer)
{
    // for normal (non headshot) kills replace "MOD_HEAD_SHOT" with "MOD_RIFLE_BULLET" and replace "head" with "torso"
    self thread [[level.callbackPlayerDamage]]( attackingPlayer, attackingPlayer, 100, 8, "MOD_HEAD_SHOT", attackingPlayer getCurrentWeapon(), (0,0,0), (0,0,0), "head", 0, 0 );
}

ZombiesDamage(attackingPlayer)
{
    self dodamage(self.health * 5000, (0,0,0), attackingPlayer);
}
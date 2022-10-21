#include maps\mp\_utility;

Init()
{
	if (GetDvarInt("mapvote_enable"))
	{
		replaceFunc(maps\mp\gametypes\_killcam::finalkillcamwaiter, ::OnKillcamEnd);
	}
}

OnKillcamEnd()
{
    if (!IsDefined(level.finalkillcam_winner))
	{
	    if (isRoundBased() && !wasLastRound())
			return false;	
		wait 3;
		
		level notify("mapvote_vote_start");
		level waittill("mapvote_vote_end");
        return false;
    }
	
    level waittill("final_killcam_done");
	if (isRoundBased() && !wasLastRound())
		return true;
	wait 3;

	level notify("mapvote_vote_start");
	level waittill("mapvote_vote_end");	
    return true;
}
/*
All the credits for this script go to DoktorSAS for both the source code and for helping me figuring this out
https://github.com/DoktorSAS/PlutoniumT6Mapvote/blob/master/Zombies/mapvote.gsc

menuSounds = array("zmb_meteor_activate", "zmb_spawn_powerup", "zmb_powerup_grabbed", "zmb_switch_flip", "zmb_elec_start", "zmb_perks_packa_ready");
*/

#include common_scripts\utility;
#include maps\mp\_utility;

Init()
{
	if (GetDvarInt("mapvote_enable"))
	{
		replaceFunc(maps\mp\zombies\_zm::intermission, ::OnIntermissionStart);
	}
}

OnIntermissionStart()
{
	level.intermission = 1;
	level notify("intermission");

	for (i = 0; i < level.players.size; i++)
	{
		level.players[i] thread player_intermission();
		level.players[i] hide();
		level.players[i] setclientuivisibilityflag("hud_visible", 0);

		level.players[i] setclientthirdperson(0);
		level.players[i].health = 100;
		level.players[i] stopsounds();
		level.players[i] stopsounds();
	}

	wait GetDvarInt("mapvote_display_wait_time");
	
	[[level.mapvote_start_function]]();
	[[level.mapvote_end_function]]();

	for (i = 0; i < level.players.size; i++)
	{
		level.players[i] notify("_zombie_game_over");
		level.players[i].sessionstate = "intermission";
	}

	players = get_players();
	i = 0;
	while (i < players.size)
	{
		setclientsysstate("levelNotify", "zi", players[i]);
		i++;
	}
	wait 0.25;
	players = get_players();
	i = 0;
	while (i < players.size)
	{
		setclientsysstate("lsm", "0", players[i]);
		i++;
	}
	level thread maps\mp\zombies\_zm::zombie_game_over_death();
}

player_intermission()
{
	self closemenu();
	self closeingamemenu();

	level endon("stop_intermission");
	self endon("disconnect");
	self endon("death");

	self.score = self.score_total;

	self.spectatorclient = -1;
	self.killcamentity = -1;
	self.archivetime = 0;
	self.psoffsettime = 0;
	self.friendlydamage = undefined;
	points = getstructarray("intermission", "targetname");
	if (!isDefined(points) || points.size == 0)
	{
		points = getentarray("info_intermission", "classname");

		location = getDvar("ui_zm_mapstartlocation");
		for(i = 0;i < points.size;i++)
	    {
		    if(points[i].script_string == location)
		    {
			    points = points[i];
		    }
	    }

		if (points.size < 1)
		{
			return;
		}
	}
	if (isdefined(self.game_over_bg))
		self.game_over_bg destroy();
	org = undefined;
	while (1)
	{
		points = array_randomize(points);
		i = 0;
		while (i < points.size)
		{
			point = points[i];
			if (!isDefined(org))
			{
				self spawn(point.origin, point.angles);
			}
			if (isDefined(points[i].target))
			{
				if (!isDefined(org))
				{
					org = spawn("script_model", self.origin + vectorScale((0, 0, -1), 60));
					org setmodel("tag_origin");
				}
				org.origin = points[i].origin;
				org.angles = points[i].angles;
				j = 0;
				while (j < get_players().size)
				{
					player = get_players()[j];
					player camerasetposition(org);
					player camerasetlookat();
					player cameraactivate(1);
					j++;
				}
				speed = 20;
				if (isDefined(points[i].speed))
				{
					speed = points[i].speed;
				}
				target_point = getstruct(points[i].target, "targetname");
				dist = distance(points[i].origin, target_point.origin);
				time = dist / speed;
				q_time = time * 0.25;
				if (q_time > 1)
				{
					q_time = 1;
				}
				org moveto(target_point.origin, time, q_time, q_time);
				org rotateto(target_point.angles, time, q_time, q_time);
				wait(time - q_time);
				wait q_time;
				i++;
				continue;
			}
			i++;
		}
	}
}
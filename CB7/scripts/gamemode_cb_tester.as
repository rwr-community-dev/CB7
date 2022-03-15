// internal
#include "metagame.as"
#include "log.as"

#include "path://media/packages/CB7/scripts"
#include "basic_command_handler.as"
#include "emp_grenade.as"
#include "gps_laptop.as"
#include "repair_crane.as"
#include "a10_gun_run.as"
#include "gunship_run.as"
#include "squad_equipment_kit.as"
#include "call_marker_tracker.as"
#include "rangefinder.as"
// #include "spawn_with_dir.as"

class GameModeCBTester : Metagame {
    GameModeCBTester(const XmlElement@ settings) {
        super(settings.getStringAttribute("log_level"));
    }

    void init() {
        Metagame::init();

        preBeginMatch();
        postBeginMatch();
    }

    void preBeginMatch() {
		_log("preBeginMatch", 1);

		// all trackers are cleared when match is about to begin
		Metagame::preBeginMatch();

		setupDogs();
	}

    void postBeginMatch() {
        Metagame::postBeginMatch();

        addTracker(BasicCommandHandler(this));
        addTracker(EmpGrenade(this));
        addTracker(GpsLaptop(this));
        addTracker(A10GunRun(this));
        addTracker(AC130GunRun(this));
        addTracker(RepairCrane(this));
        addTracker(SquadEquipmentKit(this));
        addTracker(RangeFinder(this));
        // vfs related
        /* addTracker(SpawnWithDir(this)); */

        array<CallMarkerConfig@> configs = {
            //CallMarkerConfig(string key, int atlasIndex = 0, float size = 2.0, float range = 1.0, string text = "")
            CallMarkerConfig("mortar1.call", "call_marker", 6, 0.5, 30.0),
            CallMarkerConfig("mortar2.call", "call_marker", 7, 0.5, 50.0),
            CallMarkerConfig("artillery1.call", "call_marker", 8, 1.0, 90.0),
            CallMarkerConfig("artillery2.call", "call_marker", 9, 1.0, 90.0),
            CallMarkerConfig("paratroopers1.call", "call_marker_drop", 10, 0.5),
            CallMarkerConfig("paratroopers2.call", "call_marker_drop", 11, 0.5),
            CallMarkerConfig("paratroopers_medic.call", "call_marker_drop", 14, 0.5),
            CallMarkerConfig("humvee.call", "call_marker_drop", 12, 0.5),
            CallMarkerConfig("buggy.call", "call_marker_drop", 12, 0.5),
            CallMarkerConfig("supply_quad.call", "call_marker_drop", 13, 0.5),
            CallMarkerConfig("tank.call", "call_marker_drop", 12, 0.5),
            CallMarkerConfig("cover_drop.call", "call_marker_drop", 13, 0.5),
            //CallMarkerConfig("a10_gun_run.call", "call_marker", 4, 0.5) //handled in a10_gun_run.as
            CallMarkerConfig("f22_airstrike.call", "call_marker", 4, 0.5, 40.0),
            CallMarkerConfig("gunship_run.call", "call_marker_gunship", 4, 1.0, 70.0)
        };

        addTracker(CallMarkerTracker(this, configs));

        XmlElement element(dictionary = {{"TagName", "command"},{"class", "chat"},{"text", "WELCOME TO CB TESTING! :)"}});
        m_comms.send(element);

        const XmlElement@ player = getPlayerInfo(this, 0);
        if (player !is null) {
            string username = player.getStringAttribute("name");
            // add local player as admin for easy testing, hacks, etc
            if (!getAdminManager().isAdmin(username)) {
                getAdminManager().addAdmin(username);
            }
        }
    }

    protected void setupDogs() {
		{
			// enable dogs in friendly faction only
			XmlElement command("command");
			command.setStringAttribute("class", "faction");
			command.setIntAttribute("faction_id", 0);
			command.setStringAttribute("soldier_group_name", "dog");
			command.setFloatAttribute("spawn_score", 0.5f);
			getComms().send(command);
        }

//		for (uint i = 1; i < m_factions.size(); ++i) {
//			const FactionConfig@ config = m_factions[i].m_config;
//		{
//			// disable dogs in enemy factions
//			// to prevent players to have to kill dogs
//			XmlElement command("command");
//			command.setStringAttribute("class", "faction");
//			command.setIntAttribute("faction_id", i);
//			command.setStringAttribute("soldier_group_name", "dog");
//			command.setFloatAttribute("spawn_score", 0.0f);
//			getComms().send(command);
//		}
      }
}


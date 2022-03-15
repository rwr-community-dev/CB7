// declare include paths
#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/CB7/scripts"

#include "gamemode_invasion.as"
// HACK: [CB7] include trackers here for late addition to a derived GameModeInvasion metagame
/* #include "rangefinder.as"
#include "spawn_with_dir.as" */
//torch and hollewasdad (hmmm i forgot how to spill it , the fastival people dress up as monsters) 's scripts
#include "halloween.as"
#include "repair_crane.as"

// --------------------------------------------
void main(dictionary@ inputData) {
    _setupLog("dev_verbose");
    XmlElement inputSettings(inputData);
    _log("CB7 debug: inputSettings = ");
    _log(inputSettings.toStringWithFloats());
    UserSettings settings;
    // HACK: [CB7] set the username from the local inputData as this main begins at campaign entry script
    string username = "";
    if (!inputData.get("username", username)) {
        _log("username key not in inputData dict");
    }
    settings.m_username = username;
    settings.m_factionChoice = 0;                   // 0 (greenbelts), 1 (graycollars), 2 (brownpants)
    settings.m_playerAiCompensationFactor = 1.0;
    settings.m_enemyAiAccuracyFactor = 0.95;
    settings.m_playerAiReduction = 0.0;             // didn't work before 1.76! (was 1.0)
    settings.m_teamKillPenaltyEnabled = false;      // HACK: mod for CB7 tester invasion
    settings.m_completionVarianceEnabled = false;
    settings.m_journalEnabled = false;              // HACK: mod for CB^ tester invasion
    settings.m_fellowDisableEnemySpawnpointsSoldierCountOffset = 1;
    // HACK: [CB7] some of these CB7 things require XP and RP, improve reward factor and starting amounts
    settings.m_xpFactor = 5.0;
    /* settings.m_rpFactor = 1.0; */
    settings.m_initialXp = 100.0;
    settings.m_initialRp = 1000000.0;
    // HACK: [CB7] when there aren't enough enemies around, test these weapons on your allies instead XD
    settings.m_friendlyFire = true;
    // HACK: [CB7] enable testing tools!
    settings.m_testingToolsEnabled = true;


    array<string> overlays = { "media/packages/invasion", "media/packages/CB7" };
    settings.m_overlayPaths = overlays;

    // HACK: [CB7] don't automatically start a server for CB7 testing
    /* settings.m_startServerCommand = """
<command class='start_server'
    server_name='MyInvasion'
    server_port='1240'
    comment='Coop campaign'
    url=''
    register_in_serverlist='1'
    mode='COOP'
    persistency='forever'
    max_players='32'>
    <client_faction id='0' />
</command>
"""; */

    settings.print();
    GameModeInvasion metagame(settings);
    metagame.init();
    // HACK: [CB7] add local player as admin for easy testing, hacks, etc
    if (!metagame.getAdminManager().isAdmin(metagame.getUserSettings().m_username)) {
        metagame.getAdminManager().addAdmin(metagame.getUserSettings().m_username);
    }
    // HACK: [CB7] late add CB7 trackers
    /* metagame.addTracker(RangeFinder(metagame));
    metagame.addTracker(SpawnWithDir(metagame)); */
    metagame.addTracker(Halloween(metagame));
    metagame.addTracker(RepairCrane(metagame));


    metagame.run();
    metagame.uninit();

    _log("ending execution");
}

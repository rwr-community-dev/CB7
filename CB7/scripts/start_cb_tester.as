#include "path://media/packages/vanilla/scripts"
#include "path://media/packages/CB7/scripts"
#include "gamemode_cb_tester.as"

void main(dictionary@ inputData) {
    XmlElement inputSettings(inputData);
    _log("[cb_tester main] input settings:  " + inputSettings.toString());

    GameModeCBTester metagame(inputSettings);

    metagame.init();
    metagame.run();
    metagame.uninit();

    _log("ending execution");
}

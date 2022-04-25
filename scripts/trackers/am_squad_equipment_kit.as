#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"
#include "query_helpers.as"
#include "query_helpers2.as"

//Author: Unit G17
//Author: MR. BANG (reduced complexity)

// hack: in cb7 test package for development testing, not for submission

class am_squad_equipment_kit : Tracker {
    protected Metagame@ m_metagame;

    // --------------------------------------------
    am_squad_equipment_kit(Metagame@ metagame) {
        @m_metagame = @metagame;
    }

    // --------------------------------------------
    protected void handleResultEvent(const XmlElement@ event) {
        // squad equipment kit notify_script key
        string key = "am_squad_equipment_kit";
        // checking if the event was triggered by a squad equipment kit
        string eventKey = event.getStringAttribute("key");
        if (key == eventKey) {
            // deploying character's id
            int characterId = event.getIntAttribute("character_id");
            // announcing deployment
            sendFactionMessageKeySaidAsCharacter(m_metagame, 0, characterId, "squad_equipment_kit, done");
            // maximum number of soldiers that may receive equipment
            int max_soldier_count = 10;
            // effect radius
            float range = 30.0;

            // extracting the faction id of the soldier that deployed the kit
            const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
            if (character !is null) {
                int factionId = character.getIntAttribute("faction_id");
                // extracting the position of said soldier
                Vector3 position = stringToVector3(event.getStringAttribute("position"));
                // collecting all nearby soldiers
                array<const XmlElement@>@ characters = getCharactersNearPosition(m_metagame, position, factionId, range);
                // counting the number of soldiers that have received new vests so far
                int soldier_count = 0;
                // total number of nearby soldiers
                uint total_soldier_count = characters.length();
                // running script for nearby soldiers
                for (uint i = 0; i < total_soldier_count; ++i) {
                    // randomizing selection
                    int k = rand(0, characters.length() - 1);
                    // extracting character id
                    int soldierId = characters[k].getIntAttribute("id");
                    string newVest = "am_vest_kit_proxy.carry_item";
                    // equipping them with the new vest
                    XmlElement c("command");
                    c.setStringAttribute("class", "update_inventory");
                    c.setIntAttribute("character_id", soldierId);
                    c.setIntAttribute("container_type_id", 4);
                    XmlElement j("item");
                    j.setStringAttribute("class", "carry_item");
                    j.setStringAttribute("key", newVest);
                    c.appendChild(j);
                    m_metagame.getComms().send(c);

                    // checking how many soldiers have received a new vest so far
                    soldier_count++;
                    if (soldier_count >= max_soldier_count) {
                        break;
                    }

                    // removing the selected soldier from the list
                    characters.removeAt(k);
                }
            }
        }
    }
}

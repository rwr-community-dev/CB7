#include "tracker.as"


class RPCTracker : Tracker {
	protected Metagame@ m_metagame;

	// --------------------------------------------
	RPCTracker(Metagame@ metagame) {
		@m_metagame = @metagame;
	}

	protected void handleResultEvent(const XmlElement@ event) {
		if (event.getStringAttribute("key") == "rpc") {
			int characterId = event.getIntAttribute("character_id");
			const XmlElement@ character = getCharacterInfo(m_metagame, characterId);
			if (character !is null) {
				Vector3 position = stringToVector3(event.getStringAttribute("position"));
				int factionId = character.getIntAttribute("faction_id");
				if (factionId < 0) {
					factionId = 0;
				}
				Vector3 offset = Vector3(0, 0, 0);
				float dist = 999;
				int trackRange = 15;

				// find nearby targets, filtered for enemy factions only
				array<int> enemyFactions = {0, 1, 2};
				enemyFactions.removeAt(enemyFactions.find(factionId));
				for (uint i = 0; i < enemyFactions.length(); i++) {
					array<const XmlElement@>@ enemies = getCharactersNearPosition(m_metagame, position, enemyFactions[i], 15);
					for (uint j = 0; j < enemies.length(); ++j) {
						// for each enemy, calculate distance from RPC landing position to enemy
						int enemyId = enemies[j].getIntAttribute("id");
						Vector3 enemyPos = stringToVector3(getCharacterInfo(m_metagame, enemyId).getStringAttribute("position"));
						float xdiff = enemyPos.m_values[0] - position.m_values[0];
						float ydiff = enemyPos.m_values[1] - position.m_values[1];
						float zdiff = enemyPos.m_values[2] - position.m_values[2];
						float hypotenusesq = pow(xdiff, 2) + pow(zdiff, 2);
						// and if it's closer than what we've had before, save our new target's direction
						if (pow(dist, 2) > hypotenusesq) {
							offset = Vector3(xdiff, ydiff, zdiff);
							dist = sqrt(hypotenusesq);
						}
					}
				}

				if (dist == 999) {
					// if no valid target found, chainsaw bounces along current path
					// or more precisely, away from player (at reduced speed)
					Vector3 plrPos = stringToVector3(character.getStringAttribute("position"));
					float xdiff = position.m_values[0] - plrPos.m_values[0];
					float ydiff = position.m_values[1] - plrPos.m_values[1];
					float zdiff = position.m_values[2] - plrPos.m_values[2];
					offset = Vector3(xdiff/3, ydiff/3, zdiff/3);
					// doesn't handle wall ricochets, but i don't think that's even possible to handle
				}

				// haha vroom vroom chainsaw go brrrrr
				string c = 
					"<command class='create_instance'" +
					" faction_id='" + factionId + "'" +
					" instance_class='grenade'" +
					" instance_key='rpc_rocket2.projectile'" +
					" position='" + position.add(Vector3(0, 0.5, 0)).toString() + "'" +
					" character_id='" + characterId + "'" + 
					" offset='" + Vector3(offset.m_values[0]/20, offset.m_values[1]/20 + 0.05, offset.m_values[2]/20).toString() + "' />";
				m_metagame.getComms().send(c);

				// make fake surface-scratching rocket
				string d = 
					"<command class='create_instance'" +
					" faction_id='" + factionId + "'" +
					" instance_class='grenade'" +
					" instance_key='rpc_rocket_fakescratcher.projectile'" +
					" position='" + position.toString() + "'" +
					" character_id='" + characterId + "' />";
				m_metagame.getComms().send(d);
			}

		}
	}


}
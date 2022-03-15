#include "tracker.as"
#include "helpers.as"
#include "admin_manager.as"
#include "log.as"  
#include "query_helpers.as"
#include "query_helpers2.as" 

//code by square around 8/29
//11:39:11: SCRIPT:  received: TagName=character_kill key= method_hint=stab     TagName=killer block=12 14 dead=0 faction_id=0 id=11 leader=1 name=Nikita Sokol player_id=0 position=428.551 4.3014 499.254 rp=60 soldier_group_name=default squad_size=0 wounded=0 xp=0     TagName=target block=12 14 dead=0 faction_id=1 id=9 leader=1 name=Uwe Neururer player_id=-1 position=428.102 4.30089 498.737 rp=0 soldier_group_name=default_ai squad_size=2 wounded=0 xp=0 
//agName=player aim_target=491.566 4.21569 509.884 character_id=21 color=0.68 0.85 0 1 faction_id=0 name=MR. GREEN player_id=0 profile_hash=ID3446646883 sid=ID0 

class werewolfKill 
{
	int m_characterId;
	float m_time;
	int m_killNum;

	werewolfKill(int characterId,int time)
	{
		m_characterId = characterId;
		m_time = time;
		m_killNum = 1;
	}
}



class Halloween : Tracker {
	protected Metagame@ m_metagame;


	protected array<werewolfKill@> werewolfKillLine;
	// --------------------------------------------
	Halloween(Metagame@ metagame) {
		_log("start it");
		@m_metagame = @metagame;
		m_metagame.getComms().send("<command class='set_metagame_event' name='character_kill' enabled='1' />");

	}

	// --------------------------------------------
	bool hasEnded() const {
		return false;
	}

	// -------------------------------------------- 
	bool hasStarted() const {
		return true;
	}



	protected void handleCharacterKillEvent(const XmlElement@ event) 
	{
		if(event.getFirstElementByTagName("killer").getIntAttribute("player_id") == -1)return;

		int killerId = event.getFirstElementByTagName("killer").getIntAttribute("id");
		array<const XmlElement@>@ equipment = getCharacterInfo2(m_metagame,killerId).getElementsByTagName("item");
		string vestKey = equipment[4].getStringAttribute("key");

		if(vestKey!="costume_bat_1" && vestKey!="costume_werewolf.carry_item")return;

		string Position = event.getFirstElementByTagName("killer").getStringAttribute("position");
		float killDis = getPositionDistance(stringToVector3(Position),stringToVector3(event.getFirstElementByTagName("target").getStringAttribute("position")));
		int killerF = event.getFirstElementByTagName("killer").getIntAttribute("faction_id");
		int targetF = event.getFirstElementByTagName("target").getIntAttribute("faction_id");
		//vampire
		if( equipment[4].getIntAttribute("amount")>0 && vestKey=="costume_bat_1" && killerF!=targetF && killDis<5.0f )
		{
			//vest
			XmlElement c1("command");
			c1.setStringAttribute("class", "update_inventory");
			c1.setIntAttribute("character_id", killerId); 
			c1.setIntAttribute("untransform_count", 1);
			m_metagame.getComms().send(c1);
			//projectile
			string c2 = 
			"<command class='create_instance'" +
			" instance_class='grenade'" +
			" instance_key='vampire.projectile'" +
			" position='" + Position + "'" +
			" character_id='" + killerId + "'" +
			" offset='0,0,0' />";
			m_metagame.getComms().send(c2);
			return;
		}


		//werewolf
		if( equipment[4].getIntAttribute("amount")>0 && vestKey=="costume_werewolf.carry_item" && killerF!=targetF && killDis<5.0f )
		{

			float lstime = 0.0f;
			int maxn =  werewolfKillLine.length();

			for(int i=0;i<maxn;i++)
			{
				lstime += werewolfKillLine[i].m_time;
				if(werewolfKillLine[i].m_characterId == killerId)
				{
					werewolfKillLine[i].m_killNum ++;
					if(werewolfKillLine[i].m_killNum >5)
					{

							XmlElement c("command");
							c.setStringAttribute("class", "update_inventory");

							c.setIntAttribute("character_id", killerId); 
							c.setIntAttribute("container_type_id", 4);
							{
								XmlElement j("item");
								j.setStringAttribute("class", "carry_item");
								j.setStringAttribute("key", "costume_werewolf_2");
								c.appendChild(j);
							}
							m_metagame.getComms().send(c);

							string c2 = 
							"<command class='create_instance'" +
							" instance_class='grenade'" +
							" instance_key='werewolf.projectile'" +
							" position='" + Position + "'" +
							" character_id='" + killerId + "'" +
							" offset='0,0,0' />";
							m_metagame.getComms().send(c2);

						if(i+1 < maxn)
						{
							werewolfKillLine[i+1].m_time += werewolfKillLine[i].m_time;
						}
						werewolfKillLine.removeAt(i);	
					}
					return;
				}
			}

			werewolfKillLine.insertLast(werewolfKill(killerId,60.0f - lstime));





		}

	}

	void update(float time) {
		//check the werewolf
		if(werewolfKillLine.length()>0)
		{
			werewolfKillLine[0].m_time -= time;
			if(werewolfKillLine[0].m_time < 0.0f)
			{
				werewolfKillLine.removeAt(0);
			}			
		}

	}
}


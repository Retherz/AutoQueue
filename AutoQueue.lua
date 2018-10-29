--AutoQueue_NextCast, AutoQueue_Cooldown, AutoQueue_Target, AutoQueue_SpellName, AutoQueue_Keyword = 0, nil, nil, "Blessing of Protection", "BOP";
local AutoQueue_NextCast = 0;
local printQueue, hasCast = true, false;
function AutoQueue()
	local className, class = UnitClass("player")
	if class=="PALADIN" then
		DEFAULT_CHAT_FRAME:AddMessage("AutoQueue loaded.", 0.26, 0.97, 0.26);
		this:RegisterEvent("CHAT_MSG_WHISPER");
		this:RegisterEvent("UNIT_AURA");
		AutoQueue_SpellName = "Blessing of Protection";
		AutoQueue_Keyword = "BOP";
	elseif class=="PRIEST" then
		DEFAULT_CHAT_FRAME:AddMessage("AutoQueue loaded.", 0.26, 0.97, 0.26);
		this:RegisterEvent("CHAT_MSG_WHISPER");
		this:RegisterEvent("UNIT_AURA");
		AutoQueue_SpellName = "Power Infusion";
		AutoQueue_Keyword = "PI";
		AutoQueue_Cooldown = 180;
	end
end

function AutoQueue_OnEvent()
	if(hasCast and event == "UNIT_AURA" and AutoQueue_Target == arg1) then
		TargetUnit(AutoQueue_Target);
		CastSpellByName(AutoQueue_SpellName);
		TargetLastTarget();
		AutoQueue_Target = nil;
		AutoQueue_NextCast = GetTime() + AutoQueue_Cooldown;
		hasCast = false;
	end
	if(arg1 == AutoQueue_Keyword) then
	AutoQueue_SetCD();
		for i=1,40 do
			AutoQueue_Target, _, _, _, _, _, _, _, _ = GetRaidRosterInfo(i);
			if(AutoQueue_Target == arg2) then
				AutoQueue_Target = "raid" .. i;
				if(printQueue) then DEFAULT_CHAT_FRAME:AddMessage(AutoQueue_SpellName .. " -> " .. arg2); end
				break;
			end
			AutoQueue_Target = nil;
		end
	end
end

function CastQueued()
	if(AutoQueue_NextCast < GetTime() and AutoQueue_Target ~= nil) then
		SpellStopCasting();
		TargetUnit(AutoQueue_Target);
		CastSpellByName(AutoQueue_SpellName);
		TargetLastTarget();
		hasCast = true;
	end
end

function AutoQueue_SetCD()
	if(AutoQueue_Cooldown == nil) then	
	local className, class = UnitClass("player")
		if(class=="PALADIN") then
			local _, _, _, _, talent , _ = GetTalentInfo(2, 4);
			if(talent == nil) then talent = 0; end
			AutoQueue_Cooldown = 300 - talent * 60;	
		elseif(class=="PRIEST") then		
		local _, _, _, _, talent , _ = GetTalentInfo(1, 15);
		if(talent == nil) then AutoQueue_Cooldown = 99999999; end		
			AutoQueue_Cooldown = 180;
		end
	end
end
aArcaneDeviceListView = {
			sTitleRes = "item_grouped_title_arcanedevice",
			aColumns = {
				{ sName = "name", sType = "string", sHeadingRes = "item_label_name", nWidth=180 },
				{ sName = "cost", sType = "string", sHeadingRes = "item_label_cost", nWidth=80, bCentered=true },
				{ sName = "weight", sType = "number", sHeadingRes = "item_label_weight", nWidth=60, bCentered=true }
			},
			aFilters = { 
				{ sCustom = "item_isarcanedevice"}
			},
			aGroups = {{ sDBField = "group" } },
			aGroupValueOrder = {},
		}
		
function onInit()
	ItemManager2.registerItemType("arcanedevice", "arcanedevices", false);
	DB.addHandler("charsheet.*.arcanedevices.*", "onDelete", arcaneDeviceDeletion)
	DB.addHandler("charsheet.*.arcanedevices.*.name", "onUpdate", arcaneDeviceRenamed)
	DB.addHandler("charsheet.*.arcanedevices.*.activationroll", "onUpdate", arcaneDeviceActivationRollChanged)
	DB.addHandler("charsheet.*.arcanedevices.*.powerlist.*.name", "onUpdate", arcaneDevicePowerRenamed)
	LibraryData.setCustomFilterHandler("item_isarcanedevice", isArcaneDevice)
	
	item_record_info = LibraryData.getRecordTypeInfo("item");
	
	table.insert(item_record_info.aDataMap,"arcanedevice")
	table.insert(item_record_info.aDataMap, "reference.arcanedevice")
	table.insert(item_record_info.aDataMap,"arcanedevices")
	table.insert(item_record_info.aDataMap, "reference.arcanedevices")
	
	old_fRecordDisplayClass = item_record_info.fRecordDisplayClass
	old_fIsRecordDisplayClass = item_record_info.fIsRecordDisplayClass
	item_record_info.fRecordDisplayClass = function (vNode)
			if(isArcaneDevice(vNode)) then
				return "arcanedevice";
			end
			return old_fRecordDisplayClass(vNode);
		end
	item_record_info.fIsRecordDisplayClass = function (sClass)
			return sClass == "arcanedevice" or old_fIsRecordDisplayClass(sClass);
		end
	table.insert(item_record_info.aGMListButtons,"button_item_arcanedevice")
	table.insert(item_record_info.aPlayerListButtons,"button_item_arcanedevice")
    table.insert(item_record_info.aGMEditButtons,"button_add_arcanedevice")
	LibraryData.setRecordTypeInfo("item", item_record_info)
	LibraryData.setListView("item","arcanedevice",aArcaneDeviceListView)

end

function arcaneDeviceDeletion(deviceToDelete)
	local character = deviceToDelete.getChild("...");
	removeCharacterADPowers(character, deviceToDelete);
end

function arcaneDeviceRenamed(arcanedevice_name)
	arcanedevice = arcanedevice_name.getParent()
	local ad_registeredPowersList = arcanedevice.getChild("powerlist")
	if(ad_registeredPowersList) then
		for id,power in pairs(ad_registeredPowersList.getChildren()) do
			local registeredPowerNodePath = power.getChild("registeredPowerPath")
			if(registeredPowerNodePath) then
				local registeredPowerNode = DB.getRoot().getChild(registeredPowerNodePath.getValue())
				if registeredPowerNode then
					registeredPowerNode.getChild("name").setValue(power.getChild("name").getValue().." ["..arcanedevice_name.getValue().."]");
					local activationtype = power.getChild("activationtype").getValue()
					if(activationtype == "Device Internal") then
						registeredPowerNode.getChild("traittype").setValue("["..arcanedevice_name.getValue().."]");
					end
				end
			end
		end
	end
	
	local registeredSkillNode = arcanedevice.getChild("registeredSkill")
	if registeredSkillNode then
		local skillnode = DB.findNode(registeredSkillNode.getValue())
		if skillnode then
			skillnode.getChild("name").setValue(arcanedevice_name.getValue());
		end
	end
end

function isArcaneDevice(vRecord, vDefault)
	
    if not vRecord then
        return false
    end
    local sPath =  vRecord.getPath()
    if sPath and string.find(sPath,"arcanedevice") then
        return true
    end
	return vRecord and vRecord.getChild("power") and vRecord.getChild("activationroll");
end

function hasDeviceInternalActivationPowers(arcanedevice)
	bHasDeviceInternalActivationPowers = false
	local powerlist = arcanedevice.getChild("powerlist")
	if(powerlist) then
		for id,power in pairs(arcanedevice.getChild("powerlist").getChildren()) do
			bHasDeviceInternalActivationPowers  = bHasDeviceInternalActivationPowers or (power.getChild("activationtype").getValue()=="Device Internal")
			if bHasDeviceInternalActivationPowers then
				break
			end
		end
	end
	return bHasDeviceInternalActivationPowers  
end

function removeCharacterADPowers(character, arcanedevice)
	local ad_registeredPowersList = arcanedevice.getChild("registeredPowers")
	if(ad_registeredPowersList) then
		for id,power in pairs(ad_registeredPowersList.getChildren()) do
			local registeredPowerNodePath = power.getChild("registeredPowerPath")
			if(registeredPowerNodePath) then
				local registeredPowerNode = DB.getRoot().getChild(registeredPowerNodePath.getValue())
				if(registeredPowerNode) then
					local registeredPowerChar = registeredPowerNode.getChild("...")
					if registeredPowerNode and registeredPowerChar.getPath() == character.getPath() then
						DB.deleteNode(registeredPowerNode);
					end
				end
			end
			power.delete()
		end
	end
	local registeredSkillNodePath = arcanedevice.getChild("registeredSkill")
	if registeredSkillNodePath then
		local registeredSkillNode = DB.getRoot().getChild(registeredSkillNodePath.getValue())
		DB.deleteNode(registeredSkillNodePath)
		if(registeredSkillNode) then
			local registeredSkillChar = registeredSkillNode.getChild("...")
			if registeredSkillChar.getPath() == character.getPath() then
				DB.deleteNode(registeredSkillNode);
			end
		end
	end
end

function onADEquipped(character, arcanedevice)
	if (hasDeviceInternalActivationPowers(arcanedevice)) then
		grantCharacterADSkill(character, arcanedevice)
	end
	local ad_powerlist = arcanedevice.getChild("powerlist")
	if ad_powerlist then
		powerlist_sortable={}
		for id,power in pairs(ad_powerlist.getChildren()) do
			table.insert(powerlist_sortable,power)
		end
		table.sort(powerlist_sortable, function(a,b) 
				return ((b.getChild("masternode") and b.getChild("masternode").getValue()~="") and not (a.getChild("masternode") and a.getChild("masternode").getValue()~="") )
			end)
		for _,power in pairs(powerlist_sortable) do
			grantCharacterADPower(character, arcanedevice, power)
		end
	end
end

function grantCharacterADSkill(character, arcanedevice)
	local deviceName = arcanedevice.getChild("name").getValue();
	local skilllist = character.getChild("skills");
	local newSkillNode = DB.createChild(skilllist);
	newSkillNode.createChild("name","string").setValue(deviceName);
	newSkillNode.createChild("skill","dice").setValue(arcanedevice.getChild("activationroll").getValue());
	newSkillNode.createChild("link","windowreference").setValue("arcanedevice",arcanedevice.getPath());
	arcanedevice.createChild("registeredSkill","string").setValue(newSkillNode.getPath());
end
	
function grantCharacterADPower(character, arcanedevice, power)
	local deviceName = arcanedevice.getChild("name").getValue();
	local char_powerlist = character.createChild("powerlist");
	local newPowerNode = DB.createChild(char_powerlist);
	DB.copyNode(power,newPowerNode);
	powername = power.getChild("name").getValue()
	newPowerNode.getChild("name").setValue(powername.." ["..deviceName.."]");
	--newPowerNode.getChild("link").setValue("powerdesc",power.getPath());
	if(power.getChild("damage")) then
		local damageexpr = power.getChild("damage").getValue()
		if(damageexpr ~= "") then
			local sActorType = CharacterManager.getActorType(character)
			WeaponManager.convertStringToDamageDice(sActorType, character, newPowerNode)
		end
	end
	local activationtype = power.getChild("activationtype").getValue()
	if (activationtype == "Device Internal") then
		newPowerNode.createChild("traittype").setValue("["..deviceName.."]");
	elseif (activationtype == "Skill") then
		local skillname = power.getChild("skillname").getValue()
		newPowerNode.createChild("traittype").setValue("["..skillname.."]");
	else
		newPowerNode.createChild("traittype").setValue(activationtype);
	end
	local ad_registeredPowersList = arcanedevice.createChild("registeredPowers")
	ad_registeredPowersList.createChild().createChild("registeredPowerPath","string").setValue(newPowerNode.getPath());
	power.createChild("registeredPowerPath","string").setValue(newPowerNode.getPath())
	local masternode = power.getChild("masternode")
	if masternode and masternode.getValue()~="" then
		local masternode_id = masternode.getValue()
		local masternode_power = arcanedevice.getChild("powerlist").getChild(masternode_id)
		if masternode_power then
			local master_reg_power_path = masternode_power.getChild("registeredPowerPath")
			if master_reg_power_path then
				local masternode_registered_power = DB.getRoot().getChild(master_reg_power_path.getValue())
				if masternode_registered_power then 
					local masternode_registered_index = masternode_registered_power.getName()
					newPowerNode.createChild("masternode","string").setValue(masternode_registered_index)
				end
			end
		end
	end
end


function arcaneDeviceActivationRollChanged(activationRoll)
	local arcanedevice = activationRoll.getParent()
	local registeredSkillPath = arcanedevice.getChild("registeredSkill")
	if(registeredSkillPath) then
		local registeredSkill = DB.getRoot().getChild(registeredSkillPath.getValue())
		if registeredSkill then
			local dice = registeredSkill.getChild("skill")
			if dice then
				dice.setValue(activationRoll.getValue())
			end
		end
	end
end

function arcaneDevicePowerRenamed(ad_power_name)
	local ad_name = ad_power_name.getParent().getParent().getParent().getChild("name")
	arcaneDeviceRenamed(ad_name)
end

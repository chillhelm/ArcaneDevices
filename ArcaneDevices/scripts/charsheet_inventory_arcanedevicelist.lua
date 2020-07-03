--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	super.onInit()
	registerMenuItem(Interface.getString("item_label_create_arcanedevice"), "insert", 5)
end

function onCarriedChanged(nodeCarried)
	local nodeChar = DB.getChild(nodeCarried, "....")
	if nodeChar then
		local nodeCarriedItem = DB.getChild(nodeCarried, "..")
		local character = DB.getChild(nodeCarriedItem, "...");
		if(nodeCarried.getValue()==2) then
			grantCharacterADPower(character, nodeCarriedItem)
		else
			removeCharacterADPower(character, nodeCarriedItem)
		end
		local sCarriedItem = ItemManager.getDisplayName(nodeCarriedItem)
		if StringManager.isNotBlank(sCarriedItem) then
			for _,vItem in pairs(DB.getChildren(nodeChar, "invlist")) do
				if vItem ~= nodeCarriedItem then
					local sLocation = DB.getValue(vItem, "location", "")
					if StringManager.equals(sCarriedItem, sLocation) then
						DB.setValue(vItem, "carried", "number", nodeCarried.getValue())
					end
				end
			end
		end
	end
	super.onCarriedChanged()
end

function updateContainers()
	ItemManager.onInventorySortUpdate(self)
end

function initializeEntry(win)
	local node = win.getDatabaseNode()
	if DB.isOwner(node) then
		DB.setValue(node, "carried", "number", 1)
		DB.setValue(node, "count", "number", 1)
		DB.setValue(node, "isidentified", "number", 1)
		maxPP = DB.getValue(node, "maxpowerpoints", 5)
		DB.setValue(node, "currentPP", "number", maxPP)
	end
end

function grantCharacterADPower(character, arcanedevice)
	local deviceName = arcanedevice.getChild("name").getValue();
	local activationtype = arcanedevice.getChild("activationtype").getValue()
	if(activationtype == "Device Internal") then
		local skilllist = character.getChild("skills");
		local newSkillNode = DB.createChild(skilllist);
		newSkillNode.createChild("name","string").setValue(deviceName);
		newSkillNode.createChild("skill","dice").setValue(arcanedevice.getChild("activationroll").getValue());
		newSkillNode.createChild("link","windowreference").setValue("arcanedevice",arcanedevice.getPath());
		arcanedevice.createChild("registeredSkill","string").setValue(newSkillNode.getPath());
	end
	
	local powerlink = arcanedevice.getChild("power");
	if not powerlink then
		return
	end
	local powerlinktype, powerpath = powerlink.getValue();
	if(powerlinktype=="powerdesc" and powerpath~="") then
		local power = DB.getRoot().getChild(powerpath);
		local powerlist = character.createChild("powerlist");
		local newPowerNode = DB.createChild(powerlist);
		DB.copyNode(power,newPowerNode);
		powername = arcanedevice.getChild("powername").getValue()
		newPowerNode.getChild("name").setValue(powername.." ["..deviceName.."]");
		newPowerNode.getChild("link").setValue(powerlinktype,powerpath);
		if(power.getChild("damage")) then
			local damageexpr = power.getChild("damage").getValue()
			if(damageexpr ~= "") then
				local sActorType = CharacterManager.getActorType(character)
				WeaponManager.convertStringToDamageDice(sActorType, character, newPowerNode)
			end
		end
		if (activationtype == "Device Internal") then
			newPowerNode.createChild("traittype").setValue("["..deviceName.."]");
		elseif (activationtype == "Skill") then
			local skillname = arcanedevice.getChild("skillname").getValue()
			newPowerNode.createChild("traittype").setValue("["..skillname.."]");
		else
			newPowerNode.createChild("traittype").setValue(activationtype);
		end
		arcanedevice.createChild("registeredPower","string").setValue(newPowerNode.getPath());
	end
end

function removeCharacterADPower(character, arcanedevice)
	local registeredPowerNodePath = arcanedevice.getChild("registeredPower")
	if registeredPowerNodePath then
		local registeredPowerNode = DB.getRoot().getChild(registeredPowerNodePath.getValue())
		DB.deleteNode(registeredPowerNodePath)
		local registeredPowerChar = registeredPowerNode.getChild("...")
		if registeredPowerNode and registeredPowerChar.getPath() == character.getPath() then
			DB.deleteNode(registeredPowerNode);
		end
	end
	local registeredSkillNodePath = arcanedevice.getChild("registeredSkill")
	if registeredSkillNodePath then
		local registeredSkillNode = DB.getRoot().getChild(registeredSkillNodePath.getValue())
		DB.deleteNode(registeredSkillNodePath)
		local registeredSkillChar = registeredSkillNode.getChild("...")
		if registeredSkillNode and registeredSkillChar.getPath() == character.getPath() then
			DB.deleteNode(registeredSkillNode);
		end
	end
end

function arcaneDeviceDeletion(deviceToDelete)
	local character = deviceToDelete.getChild("...");
	removeCharacterADPower(character, deviceToDelete);
end
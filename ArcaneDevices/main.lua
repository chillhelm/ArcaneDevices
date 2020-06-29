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
	LibraryData.setCustomFilterHandler("item_isarcanedevice", isArcaneDevice)
	
	item_record_info = LibraryData.getRecordTypeInfo("item");
	
	table.insert(item_record_info.aDataMap,"arcanedevice")
	table.insert(item_record_info.aDataMap, "reference.arcanedevice")
	
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
	LibraryData.setRecordTypeInfo("item", item_record_info)
	LibraryData.setListView("item","arcanedevice",aArcaneDeviceListView)
end

function arcaneDeviceDeletion(deviceToDelete)
	local character = deviceToDelete.getChild("...");
	removeCharacterADPower(character, deviceToDelete);
end

function removeCharacterADPower(character, arcanedevice)
	local registeredPowerNode = arcanedevice.getChild("registeredPower")
	if registeredPowerNode then
		DB.deleteNode(registeredPowerNode.getValue());
		DB.deleteNode(registeredPowerNode)
	end
	local registeredSkillNode = arcanedevice.getChild("registeredSkill")
	if registeredSkillNode then
		DB.deleteNode(registeredSkillNode.getValue());
		DB.deleteNode(registeredSkill);
	end
end

function arcaneDeviceRenamed(arcanedevice_name)
	arcanedevice = arcanedevice_name.getParent()
	local registeredPowerNode = arcanedevice.getChild("registeredPower")
	if registeredPowerNode then
		local powernode = DB.findNode(registeredPowerNode.getValue())
		if powernode then
			powernode.getChild("name").setValue(arcanedevice_name.getValue());
			powernode.getChild("traittype").setValue("["..arcanedevice_name.getValue().."]");
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
	
	return vRecord and vRecord.getChild("power") and vRecord.getChild("activationroll");
end
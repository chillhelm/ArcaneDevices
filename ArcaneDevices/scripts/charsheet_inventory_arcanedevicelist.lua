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
			ArcaneDevicesManager.onADEquipped(character, nodeCarriedItem)
		else
			ArcaneDevicesManager.removeCharacterADPowers(character, nodeCarriedItem)
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



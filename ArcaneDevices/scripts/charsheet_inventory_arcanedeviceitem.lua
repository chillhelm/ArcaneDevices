--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	onIDChanged()

	DB.createChild(getDatabaseNode(), "locked", "number").onUpdate = self.updateDescription
	DB.createChild(getDatabaseNode(), "carried", "number").onUpdate = self.updateDescription
	self.updateDescription()

	DB.createChild(getDatabaseNode(), "count", "number").onUpdate = updateMenuOptions
	updateMenuOptions()
end

function onIDChanged()
	local bID = LibraryData.getIDState("item", getDatabaseNode(), true)
	name.setVisible(bID)
	nonid_name.setVisible(not bID)

	local sParent = bID and "name" or "nonid_name"
	description.setAnchor("top", sParent, "bottom", "absolute", 5)
end

function getActorShortcut()
	return CharacterManager.getActorShortcut("pc", getDatabaseNode().getChild("..."))
end

function updateDescription()
	local sDescription = ItemManager2.getItemEffects(getDatabaseNode())
	description.setValue(sDescription)
	description.setVisible(StringManager.isNotBlank(sDescription))
end

function updateMenuOptions()
	resetMenuItems()
	local nCount = DB.getValue(getDatabaseNode(), "count", 0)
	if nCount > 1 and self.getActorShortcut() then
		registerMenuItem(Interface.getString("inventory_menu_split_into_two"), "halve", 4)
	end
end

function onMenuSelection(nOption)
	if nOption == 4 then
		ItemManager2.inventorySplitItem(self.getActorShortcut(), self)
	end
end

function equalsTo(nodeTarget)
	return ItemManager.compareFields(getDatabaseNode(), nodeTarget, true)
end
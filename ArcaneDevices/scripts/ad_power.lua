--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	local nodePower = getDatabaseNode()
	DB.addHandler(DB.getPath(nodePower, "locked"), "onUpdate", onLockUpdated)
	DB.createChild(nodePower, "effect", "string").onUpdate = effect.updateState
	DB.addHandler(DB.getPath(nodePower,"activationtype"),"onUpdate",update)
	updateEntity()
	update()
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "locked"), "onUpdate", onLockUpdated)
end

function onLockUpdated()
	CampaignDataManager2.updatePowerRecord(getDatabaseNode())
end

function getActorShortcut()
	return CharacterManager.getActorShortcut("pc", getDatabaseNode().getChild("..."))
end

function isReadOnlyState()
	local nodeRecord = getDatabaseNode()
	return WindowManager.getReadOnlyState(nodeRecord)
end

function update(bReadOnly)
	bReadOnly = isReadOnlyState()
	getDatabaseNode().setStatic(bReadOnly)
	name.update(bReadOnly)
	damageframe.update(bReadOnly)

	local bSection2 = false
	if range.update(bReadOnly) then bSection2 = true end
	if powerpoints.update(bReadOnly) then bSection2 = true end
	if duration.update(bReadOnly) then bSection2 = true end

	local bFocusOnEntry = name.hasFocus() or range.hasFocus() or powerpoints.hasFocus() or duration.hasFocus()
	effect.update(bReadOnly)
	effect.updateState(bFocusOnEntry)
	effect.setAnchor("top", "name", "bottom", "relative", bSection2 and 3 or 12)

	local node = getDatabaseNode()
	activationtype_str = node.createChild("activationtype","string").getValue()
	activationtype.update(bReadOnly)
	skillname.setEnabled((not bReadOnly) and (activationtype_str=="Skill"))
	skillname.update(bReadOnly)
	if(activationtype_str=="Skill") then
		skillname_label.setVisible(true)
		skillname.setVisible(true)
	else
		skillname_label.setVisible(false)
		skillname.setVisible(false)
	end

	updateEntity()
end

function updateEntity()
	leftanchor.setAnchor("left", "", "left", "absolute", isSubEntry() and 37 or 0)
	updateMenuItems()
end

function updateMenuItems()
	resetMenuItems()
	registerMenuItem(Interface.getString("common_info_attack"), "texttable", 3)
	registerMenuItem(Interface.getString("power_create_subpower"), "pointer", 4)
	if isSubEntry() then
		registerMenuItem(Interface.getString("power_delete_subpower"), "delete", 6)
		registerMenuItem(Interface.getString("power_delete_subpower_confirm"), "delete", 6, 7)
	else
		registerMenuItem(Interface.getString("power_delete"), "delete", 6)
		registerMenuItem(Interface.getString("power_delete_confirm"), "delete", 6, 7)
	end
end

function powerPointsVisible(bVisibility)
	powerpointslabel.setVisible(bVisibility)
	powerpoint_current.setVisible(bVisibility)
	powerpoint_max.setVisible(bVisibility)
end

function isSubEntry()
	return StringManager.isNotBlank(masternode.getValue())
end

function onMenuSelection(nOption, nSubOption)
	if nOption == 3 then
		AttackManager.openAttackInfo(getDatabaseNode())
	elseif nOption == 4 then
		local win = windowlist.createWindow()
		if StringManager.isBlank(masternode.getValue()) then
			win.masternode.setValue(getDatabaseNode().getName())
		else
			win.masternode.setValue(masternode.getValue())
		end
		local at = win.getDatabaseNode().createChild("activationtype","string")
		at.setValue("Device Internal")

		DB.setValue(win.getDatabaseNode(), "traittype", "string", DB.getValue(getDatabaseNode(), "traittype", ""))

		win.update(false)
		win.damagedice.convertStringToDamageDice()
		win.name.setFocus()
		windowlist.applySort()
	elseif nOption == 6 and nSubOption == 7 then
		getDatabaseNode().delete()
	end
end

function onDrop(x, y, draginfo)
	if draginfo.isType("benny") then
		return BennyManager.rerollAttackDrop(self.getActorShortcut(), getDatabaseNode(), draginfo)
	elseif draginfo.isType("effect") then
		return AttackManager.onEffectDrop(getDatabaseNode(), "effect", draginfo)
	end
end

function onDropCreate(nodeSource)
	damagedice.convertStringToDamageDice()
	updateEntity()
end
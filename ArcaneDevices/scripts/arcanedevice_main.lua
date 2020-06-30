--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	local node = getDatabaseNode()
	if DB.isOwner(node) then
		DB.createChild(node, "traittype", "string").onUpdate = update
		if node.getChild("isequipment") then
			node.getChild("isequipment").onUpdate = update
		end
	end
	node.createChild("activationtype","string").onUpdate=update
	update()
end

function isReadOnlyState()
	local nodeRecord = getDatabaseNode()
	return WindowManager.getReadOnlyState(nodeRecord)
end

function update()
	local bReadOnly = isReadOnlyState()

	local node = getDatabaseNode()
	
	group.update(bReadOnly)
	weight.update(bReadOnly)
	cost.update(bReadOnly)
	maxpowerpoints.update(bReadOnly)
	activationtype_str = node.getChild("activationtype").getValue()
	activationroll.setEnabled((not bReadOnly) and (activationtype_str=="Device Internal"))
	activationtype.update(bReadOnly)
	skillname.setEnabled((not bReadOnly) and (activationtype_str=="Skill"))
	skillname.update(bReadOnly)
	if(activationtype_str=="Device Internal") then
		activationroll.setVisible(true)
		activationroll_label.setVisible(true)
		skillname_label.setVisible(false)
		skillname.setVisible(false)
	elseif(activationtype_str=="Skill") then
		activationroll.setVisible(false)
		activationroll_label.setVisible(false)
		skillname_label.setVisible(true)
		skillname.setVisible(true)
	else
		activationroll.setVisible(false)
		activationroll_label.setVisible(false)
		skillname_label.setVisible(false)
		skillname.setVisible(false)
	end

	--powername.update(bReadOnly)
end

function onDrop(x,y,dropdata)
	if isReadOnlyState() then
		return false
	end
	if not dropdata.isType("shortcut") then
		return false;
	end
	local class = dropdata.isType("shortcut") and dropdata.getShortcutData()
	if not (class == 'powerdesc') then
		return false;
	end
	local nodeSource = dropdata.getDatabaseNode()

	local arcaneDevice = getDatabaseNode()
	local powerlink = arcaneDevice.getChild("power")
	powerlink.setValue(class, nodeSource.getPath())
	arcaneDevice.getChild("powername").setValue(nodeSource.getChild("name").getValue());
	return true
end


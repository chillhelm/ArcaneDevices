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
	update()
end

function isReadOnlyState()
	local nodeRecord = getDatabaseNode()
	return WindowManager.getReadOnlyState(nodeRecord)
end

function update()
	local bReadOnly = isReadOnlyState()
	
	group.update(bReadOnly)
	weight.update(bReadOnly)
	cost.update(bReadOnly)
	maxpowerpoints.update(bReadOnly)
	activationroll.setEnabled(not bReadOnly)
	powername.update(bReadOnly)
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
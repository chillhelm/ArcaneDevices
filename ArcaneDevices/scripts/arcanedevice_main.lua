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
	activationroll.setEnabled((not bReadOnly))

	powers.update(bReadOnly)
end

function onDrop(x,y,dropdata)
	if isReadOnlyState() then
		return false
	end
	return false
end


--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--
local bInit = false
local nodeSrc = nil

function onInit()
	super.onInit()
	self.initializeItems()
	
	nodeSrc = window.getDatabaseNode()
	local bReadOnly = (nodeSrc.isReadOnly() or not nodeSrc.isOwner())
	local sValue = DB.getValue(nodeSrc, getName())
	setValue(sValue)
	
	if bReadOnly then
		setComboBoxReadOnly(true)
	end
	bInit = true
	local acttypenode = nodeSrc.getChild("activationtype")
	if acttypenode then
		if acttypenode.getValue()==nil then
			acttypenode.setValue("Device Internal")
		end
	end
end

function initializeItems()
	addItems({"Device Internal", "Melee", "Ranged", "Thrown","Skill"})
end

function onValueChanged()
	if bInit and not isComboBoxReadOnly() then
		DB.setValue(nodeSrc, getName(), "string", getValue())
	end
	registeredPowerNode = nodeSrc.getChild("..registeredPowerNode")
	if(registeredPowerNode) then
		powernode = DB.getRoot().getChild(registeredPowerNode.getValue())
		if(powernode) then
			activationtype = DB.getValue(nodeSrc, getName(), "Device Internal")
			if (activationtype == "Device Internal") then
				powernode.getChild("traittype").setValue("["..deviceName.."]");
			elseif (activationtype == "Skill") then
				local skillname = arcanedevice.getChild("skillname").getValue()
				powernode.getChild("traittype").setValue("["..skillname.."]");
			else
				powernode.getChild("traittype").setValue(activationtype);
			end
		end
	end
end

function update(bReadOnly)
	setComboBoxReadOnly(bReadOnly)
end
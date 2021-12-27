--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onInit()
	super.onInit()
	self.initializeLocalRef()
	local nodeSkills = window.getDatabaseNode().getChild("skills")
end

function onSkillUpdate()
	for _,win in pairs(getWindows()) do
		win.traittype.updateType()
	end
end

function powerDropped(nodeSource, win, draginfo, x, y)
	DB.setValue(win.getDatabaseNode(), "locked", "number", 0)
	local sClass, sRecord = draginfo.getShortcutData()
	win.link.setValue(sClass, sRecord)
end

function onSortCompare(w1, w2)
	return ListManagerSW.sortCompareEntriesWithSubentries(w1, w2)
end

function onAfterCreate(win)
	win.name.setFocus()
	initializePower(win)
end

function initializePower(win)
	local node = win.getDatabaseNode()
	local at = node.createChild("activationtype","string")
	at.setValue("Device Internal")
	win.activationtype.update(win.isReadOnlyState())
end

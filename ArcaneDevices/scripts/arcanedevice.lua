--
-- Please see the license.html file included with this distribution for
-- attribution and copyright information.
--

function onReadOnlyChanged()
	header.locked.onInit()
end

function update()
	onLockChanged()
end

function onLockChanged()
	if header.subwindow then
		header.subwindow.update()
	end
	if main.subwindow then
		main.subwindow.update()
	end

	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode())
	description.setReadOnly(bReadOnly)
end

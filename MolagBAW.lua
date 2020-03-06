--[[
This Add-on is not created by, affiliated with or sponsored by ZeniMax Media Inc. or its affiliates. 
The Elder Scrolls� and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. 
All rights reserved

You can read the full terms at https://account.elderscrollsonline.com/add-on-terms]]

-- Initialized the addon names
MolagBAW = {}
MolagBAW.name = "MolagBAW"
MolagBAW.version = 1.0

-- Initializes various things; variables aptly named

-- For the addon settings menu
MolagBAW.LAM2 = LibStub("LibAddonMenu-2.0")

-- Saved beyond session variables
MolagBAW.defaults={
	unlocked=true,
	displayLeft=0,
	displayTop=0
}

function MolagBAW:Initialize()
	EVENT_MANAGER:RegisterForEvent(MolagBAW.name, EVENT_ACTION_LAYER_PUSHED, MolagBAW.OnActionLayerChange)
	EVENT_MANAGER:RegisterForEvent(MolagBAW.name, EVENT_ACTION_LAYER_POPPED, MolagBAW.OnActionLayerChange)
	EVENT_MANAGER:RegisterForUpdate(MolagBAW.name, 500, MolagBAW.UpdateWindow)
end

-- When the different layers of the screen are changed - quickslotting, settings, main display, etc.
function MolagBAW.OnActionLayerChange(eventCode, layerIndex, activeLayerIndex)
	MolagBAWWindow:SetHidden(activeLayerIndex > 0)
end

-- Loads the addon; only hit once
function MolagBAW.OnAddOnLoaded(event, addonName)
	-- The event fires each time *any* addon loads; but we only care about when our own addon loads.
	if addonName ~= MolagBAW.name then
		return
	end

	MolagBAW.SV = ZO_SavedVars:New("MolagBAWSettings", 1.0, "Settings", MolagBAW.defaults)
	MolagBAW:InitializeAddonMenu()

	EVENT_MANAGER:UnregisterForEvent(MolagBAW.name, EVENT_ADD_ON_LOADED)

	MolagBAW:Initialize()
	MolagBAW:InitControls()
end

-- Creates the addon settings menu
function MolagBAW:InitializeAddonMenu()
	local panelData = {
		type = "panel",
		name = "MolagBAW",
		displayName = "|c66ccffMolagBAW",
		author = "|c4779ce@BAWITDABAW|r",
		version = string.format("%.1f", MolagBAW.version),
		registerForRefresh = true,
		registerForDefaults = true
	}

	local optionsPanel = self.LAM2:RegisterAddonPanel("MolagBAW_Companion", panelData)
	local optionsData = {}

	table.insert(optionsData, {
		type = "description",
		text = "A simple tracker for knowing when your Molag Kena procs.",
	})
	table.insert(optionsData, {
		type = "header",
		name = "Options",
	})
	table.insert(optionsData, {
		type = "checkbox",
		name = "Turn OFF when satisfied with icon's position",
		tooltip = "ON - icon can me moved on the screen by left clicking and dragging, OFF - icon is locked in place and can not be moved",
		default = self.defaults.unlocked,
		getFunc = function() return self.SV.unlocked end,
		setFunc = function(newValue) self.SV.unlocked = newValue self:LoadPositions() end,
	})

	self.LAM2:RegisterOptionControls("MolagBAW_Companion", optionsData)	
end

-- Saves the positioning of the display window
function MolagBAW.DisplayOnMoveStop()
	MolagBAW.SV.displayLeft = MolagBAWWindow:GetLeft();
	MolagBAW.SV.displayTop = MolagBAWWindow:GetTop();
end

-- Setting the positions of the display, popup and purge indicator
function MolagBAW:LoadPositions()
	MolagBAWWindow:ClearAnchors();
	MolagBAWWindow:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, MolagBAW.SV.displayLeft, MolagBAW.SV.displayTop);

	MolagBAWWindow:SetMouseEnabled(MolagBAW.SV.unlocked) 
	MolagBAWWindow:SetMovable(MolagBAW.SV.unlocked)

	MolagBAWWindow_Timer:SetFont("$(MEDIUM_FONT)|" .. 30)
end

-- As settings are changed, hides or displays various features
function MolagBAW:InitControls()
	MolagBAW:LoadPositions()
end

-- Update th display window
function MolagBAW.UpdateWindow()
	if MolagBAW.SV.unlocked == false then
		MolagBAWWindow:SetHidden(true)
	end

	for buffIndex = 1, GetNumBuffs('player') do
		local buffName, timeStarted, timeEnding = GetUnitBuffInfo('player', buffIndex)
		local buffName = zo_strformat("<<1>>", buffName)

		if buffName == 'Overkill' then
			local currentTimeStamp = GetGameTimeMilliseconds() / 1000
			local timeLeft = timeEnding - currentTimeStamp

			MolagBAWWindow_Timer:SetText(string.format("%.0f", timeLeft))

			if timeLeft > 0 then
				MolagBAWWindow:SetHidden(false)
			else
				MolagBAWWindow:SetHidden(true)
			end
		end
	end
end

-- Update the display's icons

-- so that ESO can register the addon
EVENT_MANAGER:RegisterForEvent(MolagBAW.name, EVENT_ADD_ON_LOADED, MolagBAW.OnAddOnLoaded)
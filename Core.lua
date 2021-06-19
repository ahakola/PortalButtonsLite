--[[
	Portal Buttons Lite

	My implementation of an addon where you have custom row of buttons to hold teleport/portal spells.
	BTW. this was all done and tested under 24h so forgive me if something isn't working as expected.

	By Pampula of Mirage Raceway EU (BCClassic)
]]--
local ADDON_NAME, ns = ...

local function Debug(text, ...)
	if text then
		if text:match("%%[dfqsx%d%.]") then
			(DEBUG_CHAT_FRAME or ChatFrame3):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. format(text, ...))
		else
			(DEBUG_CHAT_FRAME or ChatFrame3):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. strjoin(" ", text, tostringall(...)))
		end
	end
end

local function Print(text, ...)
	if text then
		if text:match("%%[dfqs%d%.]") then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. format(text, ...))
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00".. ADDON_NAME ..":|r " .. strjoin(" ", text, tostringall(...)))
		end
	end
end

local db, playerClass, playerFaction, numMaxPortals
local RoTCount, RoPCount = 0, 0
local iconLMB = "|TInterface\\HELPFRAME\\NewPlayerExperienceParts:26:18:0:0:1024:512:988:1006:70:96|t"
local iconRMB = "|TInterface\\HELPFRAME\\NewPlayerExperienceParts:26:18:0:0:1024:512:988:1006:136:162|t"
local defaults = {
	profile = {
		buttonSize = 32,
		buttonGap = 3,
		layoutOrientation = true, -- true = Horizontal, false = Vertical
		skinElvUI = false,
		hideRunes = false,
		runesLineBreak = false,
		runesPosition = "TOPLEFT", -- BOTTOM, BOTTOMLEFT, BOTTOMRIGHT, LEFT, RIGHT, TOP, TOPLEFT, TOPRIGHT
		frameX = 300, frameY = 300, -- px from BOTTOMLEFT of the Screen
		Alliance = {
			Stormwind = true,
			Ironforge = true,
			Darnassus = true, 
			Exodar = true,
			Theramore = true,
			Shattrath = true
		},
		Horde = {
			Orgrimmar = true,
			Undercity = true,
			["Thunder Bluff"] = true,
			Silvermoon = true,
			Stonard = true,
			Shattrath = true
		}
	}
}
local data = {
	Alliance = {
		Portals = {
			10059, -- Stormwind
			11416, -- Ironforge
			11419, -- Darnassus
			32266, -- Exodar
			49360, -- Theramore
			33691 -- Shattrath
		},
		Teleports = {
			3561, -- Stormwind
			3562, -- Ironforge
			3565, -- Darnassus
			32271, -- Exodar
			49359, -- Theramore
			33690 -- Shattrath
		},
		Names = {
			"Stormwind",
			"Ironforge",
			"Darnassus",
			"Exodar",
			"Theramore",
			"Shattrath"
		}
	},
	Horde = {
		Portals = {
			11417, -- Orgrimmar
			11418, -- Undercity
			11420, -- Thunder Bluff
			32267, -- Silvermoon
			49361, -- Stonard
			35717 -- Shattrath
		},
		Teleports = {
			3567, -- Orgrimmar
			3563, -- Undercity
			3566, -- Thunder Bluff
			32272, -- Silvermoon
			49358, -- Stonard
			35715 -- Shattrath
		},
		Names = {
			"Orgrimmar",
			"Undercity",
			"Thunder Bluff",
			"Silvermoon",
			"Stonard",
			"Shattrath"
		}
	}
}
local showButtons = { Teleports = {}, Portals = {} }

if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then -- 2
	numMaxPortals = 5
elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then -- 5
	numMaxPortals = 6
end

local f = CreateFrame("Frame", "PortalButtonsLiteFrame", UIParent, BackdropTemplateMixin and "BackdropTemplate")
f:SetSize(42, 42)
f:SetPoint("CENTER")
f:SetBackdrop({
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeSize = 1
})
f:SetBackdropColor(0, 0, 0, 0)
f:SetBackdropBorderColor(.88, .88, .88, 0)

f:EnableMouse(true)
f:SetClampedToScreen(true)
f:SetScript("OnDragStart", f.StartMoving)
f:SetScript("OnDragStop", function(this)
	f:StopMovingOrSizing()
	db.frameX = this:GetLeft()
	db.frameY = this:GetBottom()
end)
f:SetScript("OnHide", f.StopMovingOrSizing)

f.runeCountString = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall") -- GameFontNormalTiny, GameFontWhiteTiny
f.runeCountString:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 0)

local function _updateButtons()
	local resizeCount, lastShown = 0, 0
	for i = 1, numMaxPortals do
		f["Button" .. i]:SetSize(db.buttonSize, db.buttonSize)

		local showThisButton = db[playerFaction][data[playerFaction].Names[i]]
		showButtons.Teleports[i] = IsSpellKnown(data[playerFaction].Teleports[i])
		showButtons.Portals[i] = IsSpellKnown(data[playerFaction].Portals[i])

		if showThisButton and (showButtons.Teleports[i] or showButtons.Portals[i]) then
			showButtons[i] = true
			f["Button" .. i]:Show()
			f["Button" .. i]:ClearAllPoints()
			if lastShown == 0 then
				f["Button" .. i]:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
			else
				if db.layoutOrientation then
					f["Button" .. i]:SetPoint("LEFT", f["Button" .. lastShown], "RIGHT", db.buttonGap, 0)
				else
					f["Button" .. i]:SetPoint("TOP", f["Button" .. lastShown], "BOTTOM", 0, -db.buttonGap)
				end
			end
			lastShown = i
			resizeCount = resizeCount + 1
		else
			showButtons[i] = false
			f["Button" .. i]:Hide()
		end
	end
	if db.layoutOrientation then
		f:SetSize(resizeCount * db.buttonSize + (resizeCount - 1) * db.buttonGap, db.buttonSize)
	else
		f:SetSize(db.buttonSize, resizeCount * db.buttonSize + (resizeCount - 1) * db.buttonGap)
	end
end

local function _updateReagentCount()
	RoTCount = GetItemCount(17031) or 0 -- 17031 - Rune of Teleportation
	RoPCount = GetItemCount(17032) or 0 -- 17032 - Rune of Portals

	if db.runesLineBreak then
		f.runeCountString:SetFormattedText("|cff%s%d|r\n|cff%s%d|r", RoTCount > 3 and "20ff20" or RoTCount > 0 and "ff7f3f" or "ff0000", RoTCount, RoPCount > 3 and "20ff20" or RoPCount > 0 and "ff7f3f" or "ff0000", RoPCount)
	else
		f.runeCountString:SetFormattedText("|cff%s%d|r / |cff%s%d|r", RoTCount > 3 and "20ff20" or RoTCount > 0 and "ff7f3f" or "ff0000", RoTCount, RoPCount > 3 and "20ff20" or RoPCount > 0 and "ff7f3f" or "ff0000", RoPCount)
	end

	local pointTable = {
		BOTTOM = "TOP", LEFT = "RIGHT", RIGHT = "LEFT", TOP = "BOTTOM",
		BOTTOMLEFT = db.layoutOrientation and "TOPLEFT" or "BOTTOMRIGHT",
		TOPLEFT = db.layoutOrientation and "BOTTOMLEFT" or "TOPRIGHT",
		BOTTOMRIGHT = db.layoutOrientation and "TOPRIGHT" or "BOTTOMLEFT",
		TOPRIGHT = db.layoutOrientation and "BOTTOMRIGHT" or "TOPLEFT"
	}
	f.runeCountString:ClearAllPoints()
	f.runeCountString:SetPoint(pointTable[db.runesPosition], f, db.runesPosition, 0, 0)

	if db.hideRunes then
		f.runeCountString:Hide()
	else
		f.runeCountString:Show()
	end
end

local function _skinButtons()
	if not IsAddOnLoaded("ElvUI") then return end

	local E = unpack(ElvUI)
	local S = E:GetModule("Skins")

	for i = 1, numMaxPortals do
		local teleportIcon = f["Button" .. i].icon:GetTexture() -- Store Icon
		S:HandleButton(f["Button" .. i], true) -- Strip all textures and set template
		f["Button" .. i].icon:SetTexture(teleportIcon) -- Restore Icon
		f["Button" .. i].icon:SetTexCoord(unpack(E.TexCoords)) -- Remove borders from Icon
	end
end

f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" and (...) == ADDON_NAME then
		PortalButtonsLiteDB = PortalButtonsLiteDB or {}
		local Settings = LibStub("AceDB-3.0"):New(PortalButtonsLiteDB, defaults, true)
		db = Settings.profile

		self:UnregisterEvent(event)
		self:RegisterEvent("PLAYER_LOGIN")

	elseif event == "PLAYER_LOGIN" then
		if db.frameX and db.frameY then
			f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", db.frameX, db.frameY)
		end

		local _, englishClass = UnitClass("Player")
		playerClass = englishClass
		playerFaction = UnitFactionGroup("Player")

		if playerClass ~= "MAGE" then return end
		Debug("PortalButtonsLite:", playerClass, playerFaction)

		for i = 1, numMaxPortals do
			local teleportSpellName, _, teleportIcon = GetSpellInfo(data[playerFaction].Teleports[i])
			local portalSpellName, _, portalIcon = GetSpellInfo(data[playerFaction].Portals[i])

			local btn = f["Button" .. i] or CreateFrame("Button", "PortalButtonsLiteButton" .. i, f, "SecureActionButtonTemplate, ActionButtonTemplate")
			btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			btn:SetAttribute("type", "spell")
			btn:SetAttribute("spell1", teleportSpellName)
			btn:SetAttribute("spell2", portalSpellName)
			btn:SetNormalTexture(nil) -- Strip surrounding bordertexture
			btn.icon:SetTexture(teleportIcon) -- Set Icon
			btn:SetScript("OnEnter", function(this)
				local colorCode = (not showButtons.Teleports[i]) and "|cffff0000" or "|cffffffff"
				if db.layoutOrientation then
					GameTooltip:SetOwner(this, "ANCHOR_BOTTOM", 0, -10)
				else
					GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT", 10, db.buttonSize)
				end
				GameTooltip:ClearLines()
				GameTooltip:AddLine("                    \n" .. iconLMB .. "  " .. colorCode .. teleportSpellName .. "|r")

				colorCode = (not showButtons.Portals[i]) and "|cffff0000" or "|cffffffff"
				GameTooltip:AddLine("                    \n" .. iconRMB .. "  " .. colorCode .. portalSpellName .. "|r")
				GameTooltip:Show()
			end)
			btn:SetScript("OnLeave", function(this)
				GameTooltip:Hide()
			end)

			f["Button" .. i] = btn
		end

		_updateButtons()
		_updateReagentCount()
		if db.skinElvUI then
			_skinButtons()
		end

		self:RegisterEvent("LEARNED_SPELL_IN_TAB")
		self:RegisterEvent("BAG_UPDATE")

	elseif event == "LEARNED_SPELL_IN_TAB" then
		local spellId, skillInfoIndex, isGuildPerkSpell = ...
		--Debug("PortalButtonsLite: LEARNED_SPELL_IN_TAB", spellId)

		for i = 1, numMaxPortals do
			if data[playerFaction].Teleports[i] == spellId or data[playerFaction].Portals[i] == spellId then
				_updateButtons()
				break
			end
		end

	elseif event == "BAG_UPDATE" then
		--Debug("PortalButtonsLite: BAG_UPDATE")
		_updateReagentCount()

	end
end)

-- SlashHandler
SLASH_PORTALBUTTONSLITE1 = "/portal"
SLASH_PORTALBUTTONSLITE2 = "/portals"

local moverVisible = false
SlashCmdList["PORTALBUTTONSLITE"] = function(text)
	Print("Still Alive!")

	moverVisible = not moverVisible
	f:SetMovable(moverVisible)
	f:RegisterForDrag(moverVisible and "LeftButton" or nil)

	if moverVisible then
		Print("Moving |cff20ff20enabled|r!")

		for i = 1, numMaxPortals do
			f["Button" .. i]:Hide()
		end
		f:SetBackdropColor(0, 0, 0, .5)
		f:SetBackdropBorderColor(.88, .88, .88)
	else
		Print("New position saved and moving |cffff0000disabled|r!")

		for i = 1, numMaxPortals do
			if showButtons[i] then
				f["Button" .. i]:Show()
			end
		end
		f:SetBackdropColor(0, 0, 0, 0)
		f:SetBackdropBorderColor(.88, .88, .88, 0)
	end
end

-- Config
local options = {
	name = "Portal Buttons Lite",
	type = "group",
	get = function(info) return db[ info[#info] ] end,
	set = function(info, value)
		db[ info[#info] ] = value
		_updateButtons()
		_updateReagentCount()
	end,
	args = {
		movable = {
			order = 0,
			name = string.format("To move the buttons, use slashcommand %s to enable/disable the mover frame.", "|cffffd200" .. SLASH_PORTALBUTTONSLITE1 .. "|r"), -- %s = Slashcommand
			type = "description",
			fontSize = "medium",
		},
		layoutHeader = {
			order = 100,
			type = "header",
			name = "Layout",
		},
		buttonSize = {
			order = 110,
			type = "range",
			name = "Button Size",
			desc = "Size of the invidual buttons.",
			width = "double",
			min = 16,
			max = 64,
			step = 1,
		},
		layoutOrientation = {
			order = 120,
			type = "select",
			name = "Layout Orientation",
			desc = "Select between horizontal row or vertical column of buttons.",
			values = {
				[true] = "Horizontal",
				[false] = "Vertical",
			},
		},
		buttonGap = {
			order = 130,
			type = "range",
			name = "Button Gap Size",
			desc = "Size of the gap between invidual buttons.",
			width = "double",
			min = -128,
			max = 64,
			step = 1,
		},
		skinElvUI = {
			order = 140,
			type = "toggle",
			name = "Skin with ElvUI |cffff0000*NB!*|r",
			desc = "Skin buttons in ElvUI's style.\n|cffff0000NB: Disabling this setting causes UI to reload!|r",
			set = function(info, value)
				db[ info[#info] ] = value

				if value then
					_skinButtons()
				else
					ReloadUI()
				end
			end,
		},
		runeHeader = {
			order = 200,
			type = "header",
			name = "Rune Counter",
		},
		hideRunes = {
			order = 210,
			type = "toggle",
			name = "Hide Rune Counter",
			desc = "Hide the Rune Counter -text.",
		},
		runesPosition = {
			order = 220,
			type = "select",
			name = "Rune Counter Position",
			desc = "Select between different positions for the Rune Counter -text.",
			values = {
				["BOTTOM"] = "Bottom",
				["BOTTOMLEFT"] = "Bottom Left",
				["BOTTOMRIGHT"] = "Bottom Right",
				["LEFT"] = "Left",
				["RIGHT"] = "Right",
				["TOP"] = "Top",
				["TOPLEFT"] = "Top Left",
				["TOPRIGHT"] = "Top Right",
			},
		},
		runesLineBreak = {
			order = 230,
			type = "toggle",
			name = "Double Line Rune Counter",
			desc = "Break Rune Counter -text into two lines of text instead of single line.",
		},
		portalsHeader = {
			order = 300,
			type = "header",
			name = "Portals",
		},
		Alliance = {
			name = "Alliance",
			type = "group",
			get = function(info) return db.Alliance[ info[#info] ] end,
			set = function(info, value)
				db.Alliance[ info[#info] ] = value
				_updateButtons()
			end,
			args = {},
		},
		Horde = {
			name = "Horde",
			type = "group",
			get = function(info) return db.Horde[ info[#info] ] end,
			set = function(info, value)
				db.Horde[ info[#info] ] = value
				_updateButtons()
			end,
			args = {},
		}
	}
}

for i = 1, numMaxPortals do
	options.args.Alliance.args[data.Alliance.Names[i]] = {
		order = 300 + i,
		type = "toggle",
		name = data.Alliance.Names[i],
		desc = string.format("Enable/Disable button for %s teleport and portal", "|cffffd200" .. data.Alliance.Names[i] .. "|r") -- %s name of the Teleport target
	}
	options.args.Horde.args[data.Horde.Names[i]] = {
		order = 350 + i,
		type = "toggle",
		name = data.Horde.Names[i],
		desc = string.format("Enable/Disable button for %s teleport and portal", "|cffffd200" .. data.Horde.Names[i] .. "|r") -- %s name of the Teleport target
	}
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("PortalButtonsLite", options, nil)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PortalButtonsLite", "Portal Buttons Lite")
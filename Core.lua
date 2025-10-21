--[[
	Portal Buttons Lite

	My implementation of an addon where you have custom row of buttons to hold teleport/portal spells.
	BTW. this was all done and tested under 24h so forgive me if something isn't working as expected.

	Starting with MoP (Classic), you no longer need reagents for teleport or portal spells, so the
	reagent counter and related settings are automatically disabled in MoP Classic and later versions.

	By Pampula of Mirage Raceway EU (BCClassic)
]]--
local ADDON_NAME, ns = ...

local function Debug(text, ...)
	if text then
		if text:match("%%[dfqsx%d%.]") then
			(DEBUG_CHAT_FRAME or (ChatFrame3:IsShown() and ChatFrame3 or ChatFrame4)):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. format(text, ...))
		else
			(DEBUG_CHAT_FRAME or (ChatFrame3:IsShown() and ChatFrame3 or ChatFrame4)):AddMessage("|cffff9999"..ADDON_NAME..":|r " .. strjoin(" ", text, tostringall(...)))
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
local iconLMB = CreateAtlasMarkup("NPE_LeftClick", 18, 18) --"|TInterface\\HELPFRAME\\NewPlayerExperienceParts:26:18:0:0:1024:512:988:1006:70:96|t"
local iconRMB = CreateAtlasMarkup("NPE_RightClick", 18, 18) -- "|TInterface\\HELPFRAME\\NewPlayerExperienceParts:26:18:0:0:1024:512:988:1006:136:162|t"
local defaults = {
	profile = {
		buttonSize = 32,
		buttonGap = 3, -- Set negative for reverse order
		buttonRowMaxCount = 5, -- Max number of buttons before new row/column
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
			Shattrath = true,
			Dalaran = true,
			["Tol Barad"] = true,
			["Vale of Eternal Blossoms"] = true,
			-- YOU ARE HERE --
			--[[
			Stormshield = true, -- WoD
			["Hall of the Guardian"] = true, -- Legion
			["Dalaran - Broken Isles"] = true, -- Legion
			Boralus = true, -- BfA
			Oribos = true, -- SL
			Valdrakken = true, -- DF
			Dornogal = true -- TWW
			]]--
		},
		Horde = {
			Orgrimmar = true,
			Undercity = true,
			["Thunder Bluff"] = true,
			Silvermoon = true,
			Stonard = true,
			Shattrath = true,
			Dalaran = true,
			["Tol Barad"] = true,
			["Vale of Eternal Blossoms"] = true,
			-- YOU ARE HERE --
			--[[
			Warspear = true, -- WoD
			["Hall of the Guardian"] = true, -- Legion
			["Dalaran - Broken Isles"] = true, -- Legion
			["Dazar'alor"] = true, -- BfA
			Oribos = true, -- SL
			Valdrakken = true, -- DF
			Dornogal = true -- TWW
			]]--
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
			33691, -- Shattrath
			53142, -- Dalaran - Northrend
			88345, -- Tol Barad
			132620, -- Vale of Eternal Blossoms
			-- YOU ARE HERE --
			--[[
			176246, -- Stormshield
			0,-- Hall of the Guardian (there is no Portal!)
			224871, -- Dalaran - Broken Isles
			281400, -- Boralus
			344597, -- Oribos
			395289, -- Valdrakken -- CHECK ID
			446534 -- Dornogal -- CHECK ID
			]]--
		},
		Teleports = {
			3561, -- Stormwind
			3562, -- Ironforge
			3565, -- Darnassus
			32271, -- Exodar
			49359, -- Theramore
			33690, -- Shattrath
			53140, -- Dalaran - Northrend
			88342, -- Tol Barad
			132621, -- Vale of Eternal Blossoms
			-- YOU ARE HERE --
			--[[
			176248, -- Stormshield
			193759, -- Hall of the Guardian -- CHECK ID
			224869, -- Dalaran - Broken Isles
			281403, -- Boralus
			344587, -- Oribos
			395277, -- Valdrakken -- CHECK ID
			446540 -- Dornogal -- CHECK ID
			]]--
		},
		Names = {
			"Stormwind",
			"Ironforge",
			"Darnassus",
			"Exodar",
			"Theramore",
			"Shattrath", -- TBC
			"Dalaran", -- Wrath
			"Tol Barad", -- Cata
			"Vale of Eternal Blossoms", -- MoP
			-- YOU ARE HERE --
			--[[
			"Stormshield", -- WoD
			"Hall of the Guardian", -- Legion
			"Dalaran - Broken Isles", -- Legion
			"Boralus", -- BfA
			"Oribos", -- SL
			"Valdrakken", -- DF
			"Dornogal" -- TWW
			]]--
		}
	},
	Horde = {
		Portals = {
			11417, -- Orgrimmar
			11418, -- Undercity
			11420, -- Thunder Bluff
			32267, -- Silvermoon
			49361, -- Stonard
			35717, -- Shattrath
			53142, -- Dalaran - Northrend
			88346, -- Tol Barad
			132626, -- Vale of Eternal Blossoms
			-- YOU ARE HERE --
			--[[
			176244, -- Warspear
			0, -- Hall of the Guardian (there is no Portal!)
			224871, -- Dalaran - Broken Isles
			281402, -- Dazar'alor
			344597, -- Oribos
			395277, -- Valdrakken -- CHECK ID
			446540, -- Dornogal -- CHECK ID
			]]--
		},
		Teleports = {
			3567, -- Orgrimmar
			3563, -- Undercity
			3566, -- Thunder Bluff
			32272, -- Silvermoon
			49358, -- Stonard
			35715, -- Shattrath
			53140, -- Dalaran - Northrend
			88344, -- Tol Barad
			132627, -- Vale of Eternal Blossoms
			-- YOU ARE HERE --
			--[[
			176242, -- Warspear
			193759, -- Hall of the Guardian -- CHECK ID
			224869, -- Dalaran - Broken Isles
			281404, -- Dazar'alor
			344587, -- Oribos
			395277, -- Valdrakken -- CHECK ID
			446540, -- Dornogal -- CHECK ID
			]]--
		},
		Names = {
			"Orgrimmar",
			"Undercity",
			"Thunder Bluff",
			"Silvermoon",
			"Stonard",
			"Shattrath", -- TBC
			"Dalaran", -- Wrath
			"Tol Barad", -- Cata
			"Vale of Eternal Blossoms", -- MoP
			-- YOU ARE HERE --
			--[[
			"Warspear", -- WoD
			"Hall of the Guardian", -- Legion
			"Dalaran - Broken Isles", -- Legion
			"Dazar'alor", -- BfA
			"Oribos", -- SL
			"Valdrakken", -- DF
			"Dornogal", -- TWW
			]]--
		}
	}
}
local showButtons = { Teleports = {}, Portals = {} }

if WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then -- 2
	numMaxPortals = 5
elseif WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC then -- 5
	numMaxPortals = 6
elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then -- 11
	numMaxPortals = 7
elseif WOW_PROJECT_ID == WOW_PROJECT_CATACLYSM_CLASSIC then -- 14
	numMaxPortals = 8
elseif WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC then -- 19
	numMaxPortals = 9
end

local f = CreateFrame("Frame", "PortalButtonsLiteFrame", UIParent, "BackdropTemplate")
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
	local numButtons, numRows, lastShown, lastRowStart = 0, 0, 0, 0

	local defaultButtonOrder = (db.buttonGap >= 0)
	local offsetSign, horizontalPoint, verticalPoint = 1, "LEFT", "BOTTOM"
	if not defaultButtonOrder then
		offsetSign, horizontalPoint, verticalPoint = -1, "RIGHT", "TOP"
	end
	local pointTable = { BOTTOM = "TOP", LEFT = "RIGHT", RIGHT = "LEFT", TOP = "BOTTOM" }

	for i = 1, numMaxPortals do
		f["Button" .. i]:SetSize(db.buttonSize, db.buttonSize)

		local showThisButton = db[playerFaction][data[playerFaction].Names[i]]
		showButtons.Teleports[i] = C_SpellBook.IsSpellInSpellBook(data[playerFaction].Teleports[i]) -- previously IsSpellKnown
		showButtons.Portals[i] = C_SpellBook.IsSpellInSpellBook(data[playerFaction].Portals[i]) -- previously IsSpellKnown

		if showThisButton and (showButtons.Teleports[i] or showButtons.Portals[i]) then
			showButtons[i] = true
			f["Button" .. i]:Show()
			f["Button" .. i]:ClearAllPoints()
			if lastShown == 0 then
				if db.layoutOrientation then
					f["Button" .. i]:SetPoint(("TOP" .. horizontalPoint), f, ("TOP" .. horizontalPoint), 0, 0)
				else
					f["Button" .. i]:SetPoint((verticalPoint .. "LEFT"), f, (verticalPoint .. "LEFT"), 0, 0)
				end
				numRows = 1
				lastRowStart = i
			else
				if db.layoutOrientation then
					if numButtons % db.buttonRowMaxCount == 0 then
						f["Button" .. i]:SetPoint("TOP", f["Button" .. lastRowStart], "BOTTOM", 0, (offsetSign * -db.buttonGap))
						numRows = numRows + 1
						lastRowStart = i
					else
						f["Button" .. i]:SetPoint(horizontalPoint, f["Button" .. lastShown], pointTable[horizontalPoint], db.buttonGap, 0)
					end
				else
					if numButtons % db.buttonRowMaxCount == 0 then
						f["Button" .. i]:SetPoint("LEFT", f["Button" .. lastRowStart], "RIGHT", (offsetSign * db.buttonGap), 0)
						numRows = numRows + 1
						lastRowStart = i
					else
						f["Button" .. i]:SetPoint(verticalPoint, f["Button" .. lastShown], pointTable[verticalPoint], 0, db.buttonGap)
					end
				end
			end
			lastShown = i
			numButtons = numButtons + 1
		else
			showButtons[i] = false
			f["Button" .. i]:Hide()
		end
	end
	if db.layoutOrientation then
		if numRows == 1 then
			f:SetSize(numButtons * db.buttonSize + (numButtons - 1) * math.abs(db.buttonGap), db.buttonSize)
		else
			f:SetSize(db.buttonRowMaxCount * db.buttonSize + (db.buttonRowMaxCount - 1) * math.abs(db.buttonGap), numRows * db.buttonSize + (numRows - 1) * math.abs(db.buttonGap))
		end
	else
		if numRows == 1 then
			f:SetSize(db.buttonSize, numButtons * db.buttonSize + (numButtons - 1) * math.abs(db.buttonGap))
		else
			f:SetSize(numRows * db.buttonSize + (numRows - 1) * math.abs(db.buttonGap), db.buttonRowMaxCount * db.buttonSize + (db.buttonRowMaxCount - 1) * math.abs(db.buttonGap))
		end
	end
	f.numButtons = numButtons -- Don't show ReagentCount on low level characters before they know any Teleport-spells
end

local function _updateReagentCount()
	if db.hideRunes or f.numButtons == 0 or numMaxPortals >= 9 then -- Starting with MoP (Classic), you no longer need reagents for teleport or portal spells
		f.runeCountString:Hide()
		return
	end

	RoTCount = C_Item.GetItemCount(17031) or 0 -- 17031 - Rune of Teleportation
	RoPCount = C_Item.GetItemCount(17032) or 0 -- 17032 - Rune of Portals

	local RoTString = WrapTextInColor(RoTCount, RoTCount > 3 and GREEN_FONT_COLOR or (RoTCount > 0 and ORANGE_FONT_COLOR or RED_FONT_COLOR))
	local RoPString = WrapTextInColor(RoPCount, RoPCount > 3 and GREEN_FONT_COLOR or (RoPCount > 0 and ORANGE_FONT_COLOR or RED_FONT_COLOR))

	if db.runesLineBreak then
		f.runeCountString:SetFormattedText("%s\n%s", RoTString, RoPString)
	else
		f.runeCountString:SetFormattedText("%s / %s", RoTString, RoPString)
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
	f.runeCountString:Show()
end

local function _skinButtons()
	if not C_AddOns.IsAddOnLoaded("ElvUI") then return end

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

		playerClass = UnitClassBase("Player")
		playerFaction = UnitFactionGroup("Player")

		if playerClass ~= "MAGE" then return end
		Debug("Enabled:", playerClass, playerFaction)

		for i = 1, numMaxPortals do
			local teleportSpellName, teleportIcon = C_Spell.GetSpellName(data[playerFaction].Teleports[i]), C_Spell.GetSpellTexture(data[playerFaction].Teleports[i])
			local portalSpellName = C_Spell.GetSpellName(data[playerFaction].Portals[i])

			local btn = f["Button" .. i] or CreateFrame("Button", "PortalButtonsLiteButton" .. i, f, "SecureActionButtonTemplate, ActionButtonTemplate")
			btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
			btn:SetAttribute("type", "spell")
			btn:SetAttribute("spell1", teleportSpellName)
			btn:SetAttribute("spell2", portalSpellName)
			btn:SetNormalTexture(130871) -- Strip surrounding bordertexture - 130871 = Interface/Buttons/WHITE8X8
			btn:GetNormalTexture():SetVertexColor(1, 1, 1, 0) -- Fix for Wrath Classic since it uses new DF style which can't handle :SetNormalTexture(nil)
			btn.icon:SetTexture(teleportIcon) -- Set Icon
			btn:SetScript("OnEnter", function(this)
				if db.layoutOrientation then
					GameTooltip:SetOwner(this, "ANCHOR_BOTTOM", 0, -10)
				else
					GameTooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT", 10, db.buttonSize)
				end
				GameTooltip:ClearLines()
				GameTooltip:AddLine(string.format("%s%s\n%s%s",
					iconLMB, WrapTextInColor(teleportSpellName or "n/a", (not showButtons.Teleports[i]) and RED_FONT_COLOR or WHITE_FONT_COLOR),
					iconRMB, WrapTextInColor(portalSpellName or "n/a", (not showButtons.Portals[i]) and RED_FONT_COLOR or WHITE_FONT_COLOR)
				))
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
		--self:RegisterEvent("BAG_UPDATE")
		self:RegisterEvent("BAG_UPDATE_DELAYED")

	elseif event == "LEARNED_SPELL_IN_TAB" then
		local spellId, skillInfoIndex, isGuildPerkSpell = ...
		--Debug("PortalButtonsLite: LEARNED_SPELL_IN_TAB", spellId)

		for i = 1, numMaxPortals do
			if data[playerFaction].Teleports[i] == spellId or data[playerFaction].Portals[i] == spellId then
				_updateButtons()
				break
			end
		end

	--elseif event == "BAG_UPDATE" then
	elseif event == "BAG_UPDATE_DELAYED" then
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
	f:RegisterForDrag("LeftButton")

	if moverVisible then
		Print(string.format("Moving %s!", WrapTextInColor("enabled", GREEN_FONT_COLOR)))

		for i = 1, numMaxPortals do
			f["Button" .. i]:Hide()
		end
		f:SetBackdropColor(0, 0, 0, .5)
		f:SetBackdropBorderColor(.88, .88, .88)
	else
		Print(string.format("New position saved and moving %s!", WrapTextInColor("disabled", RED_FONT_COLOR)))

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
			name = string.format("To move the buttons, use slashcommand %s to enable/disable the mover frame.", WrapTextInColor(SLASH_PORTALBUTTONSLITE1, NORMAL_FONT_COLOR)), -- %s = Slashcommand
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
			desc = "Size of the gap between invidual buttons. Use negative values for reverse order of buttons.",
			width = "double",
			min = -32,
			max = 32,
			step = 1,
		},
		skinElvUI = {
			order = 140,
			type = "toggle",
			name = string.format("Skin with ElvUI %s", WrapTextInColor("*NB!*", RED_FONT_COLOR)),
			desc = string.format("Skin buttons in ElvUI's style.\n%s", WrapTextInColor("NB: Disabling this setting causes UI to reload!", RED_FONT_COLOR)),
			set = function(info, value)
				db[ info[#info] ] = value

				if value then
					_skinButtons()
				else
					C_UI.Reload()
				end
			end,
		},
		buttonRowMaxCount = {
			order = 150,
			type = "range",
			name = "Buttons In Single Row/Column",
			desc = "The maximum number of buttons in a single row/column before starting a new one.",
			width = "double",
			min = 2,
			max = numMaxPortals,
			step = 1,
		},
		runeHeader = {
			order = 200,
			type = "header",
			name = "Rune Counter",
			hidden = numMaxPortals >= 9, -- Starting with MoP (Classic), you no longer need reagents for teleport or portal spells
		},
		hideRunes = {
			order = 210,
			type = "toggle",
			name = "Hide Rune Counter",
			desc = "Hide the Rune Counter -text.",
			hidden = numMaxPortals >= 9, -- Starting with MoP (Classic), you no longer need reagents for teleport or portal spells
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
			hidden = numMaxPortals >= 9, -- Starting with MoP (Classic), you no longer need reagents for teleport or portal spells
		},
		runesLineBreak = {
			order = 230,
			type = "toggle",
			name = "Double Line Rune Counter",
			desc = "Break Rune Counter -text into two lines of text instead of single line.",
			hidden = numMaxPortals >= 9, -- Starting with MoP (Classic), you no longer need reagents for teleport or portal spells
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
		desc = string.format("Enable/Disable button for %s teleport and portal", WrapTextInColor(data.Alliance.Names[i], NORMAL_FONT_COLOR)) -- %s name of the Teleport target
	}
	options.args.Horde.args[data.Horde.Names[i]] = {
		order = 350 + i,
		type = "toggle",
		name = data.Horde.Names[i],
		desc = string.format("Enable/Disable button for %s teleport and portal", WrapTextInColor(data.Horde.Names[i], NORMAL_FONT_COLOR)) -- %s name of the Teleport target
	}
end

LibStub("AceConfig-3.0"):RegisterOptionsTable("PortalButtonsLite", options, nil)
LibStub("AceConfigDialog-3.0"):AddToBlizOptions("PortalButtonsLite", "Portal Buttons Lite")
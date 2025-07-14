local Pentium = script.Parent
local PentiumVersion = "1.0.0"

local ActivateButton: GuiButton = nil

local TextService = game:GetService("TextService")

local ActivateModes = { Startup = 1, Button = 2 }
local ActivateMode = ActivateModes.Startup

local DelModes = { Destroy = 1, Hide = 2 }
local DelMode = DelModes.Destroy

local CreateMessage = require(script.Modules.Log).DisplayMessage
local CreateDraggable = require(script.Modules.DraggableObject).new

local CreateContextMenu = require(script.Modules.ContextMenu).CreateContextMenu
local CreateContextMenuButton = require(script.Modules.ContextMenu).CreateContextMenuButton

local UpdateAC = require(script.Modules.Autocomplete).Update
local SyntaxHighlight = require(script.Modules.Highlighting).run

local Crawl = require(script.Modules.Autocomplete).CrawlForDescendents

local PentiumClientLoadCode = require(script.Modules.vLuau)
local PentiumLoadCode = function(stuff: string)
	game.ReplicatedStorage.PentiumExecute:FireServer(stuff, "SupaS!CURE!100.253#9ui00we78ht0spdvn540PT")
end

local function CursorBlink()
	while true do
		Pentium.Main.Cursor.Visible = not Pentium.Main.Cursor.Visible
		task.wait(0.4)
	end
end

local CurrentRunContext = PentiumLoadCode

local function newline(str: string)
	return string.format("%s\n", str)
end

-- uses \n with string.split to determine the best guess for cursor position
function CursorPosition(content: string, cursor_index: number)
	cursor_index -= 1

	local RawInput = Pentium.Main.RawInput
	local x, y = 0, 1

	local split = content:split("\n")

	if cursor_index > 0 then
		for index, char in content:split("") do
			if char == "\n" then
				y += 1
				x = 0
			else
				x += 1
			end

			if index == cursor_index then
				break
			end
		end
	end

	local line = split[y]

	if line and line ~= "" then
		local line_width =
			TextService:GetTextSize(line:sub(1, x), RawInput.TextSize, RawInput.Font, RawInput.AbsoluteSize)

		return line_width.X + 30, ((y - 1) * 16) + 30
	else
		return 30, ((y - 1) * 16) + 30
	end
end

local function UpdateCursor()
	--::::: legacy cursor position code, see CursorPosition function above for current version
	-- local ScaleX = (Pentium.Main.RawInput.TextBounds.X / Pentium.Main.RawInput.AbsoluteSize.X)
	-- local ScaleY = (Pentium.Main.RawInput.TextBounds.Y / Pentium.Main.RawInput.AbsoluteSize.Y)

	-- changed Y by 25 to account for the topbar.
	-- Pentium.Main.Cursor.Position = UDim2.new(ScaleX, 25, ScaleY, 14)
	--:::::

	local CursorX, CursorY = CursorPosition(Pentium.Main.RawInput.Text, Pentium.Main.RawInput.CursorPosition)

	Pentium.Main.Cursor.Position = UDim2.fromOffset(CursorX, CursorY)

	Pentium.Main.KeywordHint.Position = UDim2.new(
		Pentium.Main.Cursor.Position.X.Scale,
		Pentium.Main.Cursor.Position.X.Offset,
		Pentium.Main.Cursor.Position.Y.Scale,
		Pentium.Main.Cursor.Position.Y.Offset + 16
	)
end

local function UpdateText()
	Pentium.Main.StyleInput.Text = SyntaxHighlight(Pentium.Main.RawInput.Text)

	local Last = string.sub(Pentium.Main.RawInput.Text, -1)
	Last = string
		.lower(Last)
		:gsub("%%", "%%%%")
		:gsub("^%^", "%%^")
		:gsub("%$$", "%%$")
		:gsub("%(", "%%(")
		:gsub("%)", "%%)")
		:gsub("%.", "%%.")
		:gsub("%[", "%%[")
		:gsub("%]", "%%]")
		:gsub("%*", "%%*")
		:gsub("%+", "%%+")
		:gsub("%-", "%%-")
		:gsub("%?", "%%?")

	if Last then
		local Chars = "abcdefghijklmnopqrstuvwxyz1234567890."
		local LastCharIsChar = Last ~= "" and string.find(Chars, Last)
		Pentium.Main.KeywordHint.Visible = LastCharIsChar or false
	else
		Pentium.Main.KeywordHint.Visible = false
	end

	local _, count = Pentium.Main.RawInput.Text:gsub("\n", "\n")

	Pentium.Main.LineNumbers.Text = ""

	for i = 1, count + 1 do
		Pentium.Main.LineNumbers.Text = Pentium.Main.LineNumbers.Text .. newline(tostring(i))
	end

	UpdateAC()
end

local function Start()
	Pentium.Splash.Visible = true

	CreateDraggable(Pentium.Main, Pentium.Main.Topbar):Enable()

	CreateContextMenu("File")
	CreateContextMenu("Code")
	CreateContextMenu("Help")

	local function Quit()
		if DelMode == DelModes.Hide then
			Pentium.Main.Visible = false
		else
			Pentium:Destroy()
		end
	end

	-- Quit buttons
	CreateContextMenuButton("File", "Quit", Quit)
	Pentium.Main.Topbar.QuitButton.MouseButton1Click:Connect(Quit)

	CreateContextMenuButton("Code", "Run", function()
		CurrentRunContext(Pentium.Main.RawInput.Text)
	end)

	CreateContextMenuButton("Help", "About Pentium", function()
		CreateMessage("About Pentium", [[Pentium Text Editor
			Version ]] .. PentiumVersion .. [[
			(C) Copyright 2025 SirKingBinx
		]])
	end)

	Crawl(game)

	UpdateText()
	UpdateCursor()

	Pentium.Main.RawInput:GetPropertyChangedSignal("Text"):Connect(UpdateText)
	Pentium.Main.RawInput:GetPropertyChangedSignal("CursorPosition"):Connect(UpdateCursor)

	coroutine.wrap(CursorBlink)()

	task.wait(2)

	Pentium.Splash.Visible = false

	Pentium.Main.Visible = true
end

if ActivateMode == ActivateModes.Button then
	ActivateButton.MouseButton1Click:Connect(Start)
else
	Start()
end

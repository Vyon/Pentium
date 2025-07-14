local Pentium = script.Parent
local PentiumVersion = "1.0.0"

local ActivateButton: GuiButton = nil

local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local ActivateModes = { Startup = 1, Button = 2 }
local ActivateMode = ActivateModes.Startup

local DelModes = { Destroy = 1, Hide = 2 }
local DelMode = DelModes.Destroy

local Config = require(script.Config)
local Log = require(script.Modules.Log)
local Execution = require(script.Modules.Execution)
local ContextMenu = require(script.Modules.ContextMenu)
local AutoComplete = require(script.Modules.Autocomplete)
local Draggable = require(script.Modules.DraggableObject)

local SyntaxHighlight = require(script.Modules.Highlighting).run

-- Functions:
local CreateContextMenu = ContextMenu.CreateContextMenu
local CreateContextMenuButton = ContextMenu.CreateContextMenuButton

local function CursorBlink()
	while true do
		Pentium.Main.Cursor.Visible = not Pentium.Main.Cursor.Visible
		task.wait(0.4)
	end
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
	elseif cursor_index < 0 then
		-- When the player unfocuses the textbox CursorPosition is set to -1 or in this context -2
		return
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
	local CursorX, CursorY = CursorPosition(Pentium.Main.RawInput.Text, Pentium.Main.RawInput.CursorPosition)

	-- Prevents issues when the input is unfocused.
	if not CursorX or not CursorY then
		return
	end

	if Config.Editor.SmoothCursor.Enabled then
		TweenService:Create(Pentium.Main.Cursor, TweenInfo.new(Config.Editor.SmoothCursor.Speed), {
			Position = UDim2.fromOffset(CursorX, CursorY),
		}):Play()
	else
		Pentium.Main.Cursor.Position = UDim2.fromOffset(CursorX, CursorY)
	end

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
		Pentium.Main.LineNumbers.Text = `{Pentium.Main.LineNumbers.Text}{i}\n`
	end

	AutoComplete.Update()
end

local function Start()
	Pentium.Splash.Visible = true

	Draggable.new(Pentium.Main, Pentium.Main.Topbar):Enable()

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

	local ContextButton

	ContextButton = CreateContextMenuButton("Code", `Context: {Execution.Context}`, function()
		local Label = ContextButton.TextLabel

		local NewContext = Label.Text:gsub("Context: ", "") == "Client" and "Server" or "Client"

		Execution.Context = NewContext

		ContextButton.TextLabel.Text = `Context: {NewContext}`
		ContextButton.TextLabel.TextColor3 = Execution.Colors[Execution.Context]
	end)

	if ContextButton then --> If the template is not found the function returns nil
		ContextButton.TextLabel.TextColor3 = Execution.Colors[Execution.Context]
	end

	CreateContextMenuButton("Code", "Run", function()
		Execution.Run(Pentium.Main.RawInput.Text)
	end)

	CreateContextMenuButton("Help", "About Pentium", function()
		Log.DisplayMessage("About Pentium", [[Pentium Text Editor
			Version ]] .. PentiumVersion .. [[
			(C) Copyright 2025 SirKingBinx
		]])
	end)

	AutoComplete.CrawlForDescendents(game)

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

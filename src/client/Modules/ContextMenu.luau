local ContextMenu = {}

local TextService = game:GetService("TextService")

ContextMenu.Script = script.Parent.Parent
ContextMenu.Menus = {}

function ContextMenu.CreateContextMenu(contentMenuName: string)
	local thisMenuButton = ContextMenu.Script.Templates.ContextMenu:Clone()
	ContextMenu.Menus[contentMenuName] = thisMenuButton

	thisMenuButton.Name = contentMenuName
	thisMenuButton.Text = string.upper(contentMenuName)

	local properXSize = 25
		+ TextService:GetTextSize(
			thisMenuButton.Text,
			thisMenuButton.TextSize,
			thisMenuButton.Font,
			Vector2.new(thisMenuButton.Size.Width, thisMenuButton.Size.Height)
		).X
	thisMenuButton.Size = UDim2.new(0, properXSize, 0, 25)

	thisMenuButton.Parent = ContextMenu.Script.Parent.Main.Topbar.ContextMenus

	thisMenuButton.MouseButton1Click:Connect(function()
		for _, menu in ContextMenu.Menus do
			if menu == thisMenuButton then
				continue
			end

			menu:FindFirstChild("ContextMenu").Visible = false
		end

		thisMenuButton.ContextMenu.Visible = not thisMenuButton.ContextMenu.Visible
	end)

	ContextMenu.Menus[contentMenuName] = thisMenuButton
end

function ContextMenu.CreateContextMenuButton(contentMenuName: string, contextMenuButton: string, action: () -> ())
	local menu = ContextMenu.Menus[contentMenuName]

	if menu then
		local button = ContextMenu.Script.Templates.ContextMenuButton:Clone()
		button.Parent = menu.ContextMenu
		button.TextLabel.Text = contextMenuButton

		local properXSize = 70
			+ TextService:GetTextSize(
				button.Text,
				button.TextSize,
				button.Font,
				Vector2.new(button.Size.Width, button.Size.Height)
			).X

		if properXSize < 200 then
			properXSize = 200
		end

		button.Size = UDim2.new(0, properXSize, 0, 25)

		if menu.ContextMenu.Size.Width.Offset < properXSize then
			menu.ContextMenu.Size = UDim2.new(0, properXSize, 0, (#menu.ContextMenu:GetChildren() - 1) * 25)
		else
			menu.ContextMenu.Size =
				UDim2.new(0, menu.ContextMenu.Size.Width.Offset, 0, (#menu.ContextMenu:GetChildren() - 1) * 25)
		end

		button.MouseButton1Click:Connect(function()
			menu.ContextMenu.Visible = false
			action()
		end)

		return button
	else
		warn("Context menu requested missing or null. arg: " .. contentMenuName)
	end

	return
end

return ContextMenu

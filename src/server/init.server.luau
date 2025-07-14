game.ReplicatedStorage.PentiumExecute.OnServerEvent:Connect(function(plr: Player, code: string)
	local playerCodePath = "game.Players." .. plr.Name .. ".PlayerGui.Pentium.Pentium.Modules.ScriptingSupport"
	local codeHeader = [[
		-- Pentium-generated code
		function ThrowError(text: string) require(]] .. playerCodePath .. [[).ThrowError(text, game.Players.]] .. plr.Name .. [[) end
		function ThrowWarn(text: string) require(]] .. playerCodePath .. [[).ThrowWarn(text, game.Players.]] .. plr.Name .. [[) end
		function ThrowInfo(text: string) require(]] .. playerCodePath .. [[).ThrowInfo(text, game.Players.]] .. plr.Name .. [[) end
		function DisplayMessage(title: string, text: string, buttons: {}) require(]] .. playerCodePath .. [[).DisplayMessage(title, text, buttons, game.Players.]] .. plr.Name .. [[) end
		function rand(tbl: {}) if tbl ~= {} then return tbl[math.random(1, #tbl)] else return nil end end
		
		]]

	local success, results: any? = pcall(function()
		local wrapped = loadstring(codeHeader .. code)

		if not wrapped then
			return
		end

		return { wrapped() }
	end)

	if success and results then
		print(table.unpack(results))
	else
		warn(`[Pentium]: Requested code from {plr.Name} failed to execute: {results}`)
	end
end)

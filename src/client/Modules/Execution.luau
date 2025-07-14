-- Services:
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules:
local Loadstring = require(script.Parent.vLuau)

-- Main Module:
local Execution = {}
Execution.Context = "Client" --> Must be either Server or Client
Execution.Env = nil :: { [string]: any }?
Execution.Colors = {
	Server = Color3.fromRGB(28, 255, 50),
	Client = Color3.fromRGB(21, 146, 255),
}

function Execution.Run(code: string)
	if Execution.Context == "Server" then
		ReplicatedStorage.PentiumExecute:FireServer(code)
	elseif Execution.Context == "Client" then
		Loadstring(code, Execution.Env, "Pentium")()
	else
		warn(`[Execution.Run]: Unknown ExecutionContext '{Execution.Context}'`)
	end
end

return Execution

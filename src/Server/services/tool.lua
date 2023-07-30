local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerScriptService = game:GetService 'ServerScriptService'
local Tools = ReplicatedStorage.Tools

local Tool = require(ServerScriptService.components.tool)

local Module = {}

function Module.getTool(toolName: string)
	return Tools:FindFirstChild(toolName) :: Tool?
end

function Module.giveTool(player: Player, toolName: string)
	local tool = Module.getTool(toolName)
	if not tool then
		return
	end

	local backpack = player:FindFirstChild 'Backpack' :: Backpack?
	if not backpack then
		return
	end

	local tool = tool:Clone()
	Tool.factory.add(tool)
	tool.Parent = backpack
end

return Module
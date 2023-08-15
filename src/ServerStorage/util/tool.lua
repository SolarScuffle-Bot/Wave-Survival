local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerStorage = game:GetService("ServerStorage")
local Tools = ReplicatedStorage.Tools

local Tool = require(ServerStorage.components.tool)

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

	local newTool = tool:Clone()
	Tool.factory.add(newTool)
	newTool.Parent = backpack
end

function Module.removeTool(player: Player, toolName: string)
	local backpack = player:FindFirstChild 'Backpack' :: Backpack?
	if not backpack then
		return
	end

	local tool = backpack:FindFirstChild(toolName) :: Tool?
	if not tool then
		return
	end

	tool:Destroy()
end

return Module

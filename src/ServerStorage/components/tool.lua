--!strict

local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local Tools = ReplicatedStorage:WaitForChild 'Tools'

local Connect = require(ReplicatedStorage.connect)

local World = require(ReplicatedStorage.world)

local Module = {}

Module.gun = World.tag 'gun'

Module.tool = World.factory(script.Name, {
	add = function(factory, entity: Tool)
		warn('add tool' .. entity.Name)

		local connections = {}

		connections.equipped = entity.Equipped:Connect(function(mouse: Mouse)
			local character = entity.Parent :: Model?
			if not character then
				entity:Destroy()
				return
			end

			local humanoid = character:FindFirstChildWhichIsA 'Humanoid'
			if not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
				entity:Destroy()
				return
			end

			connections.died = humanoid.Died:Connect(function()
				entity:Destroy()
			end)
		end)

		connections.unequipped = entity.Unequipped:Connect(function(mouse: Mouse)
			Connect.disconnect(connections, 'died')
		end)

		return connections
	end,

	remove = function(factory, entity: Mouse, component: Component)
		warn('remove tool' .. entity.Name)
		Connect.disconnect(component)
	end,
})

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
	Module.tool.add(newTool)
	newTool.Parent = backpack
end

function Module.removeTool(player: Player, toolName: string)
	local backpack = player:FindFirstChild 'Backpack' :: Backpack?
	if backpack then
		local tool = backpack:FindFirstChild(toolName) :: Tool?
		if tool then
			tool:Destroy()
		end
	end

	local character = player.Character
	if character then
		local tool = character:FindFirstChild(toolName) :: Tool?
		if tool then
			tool:Destroy()
		end
	end
end

function Module.unequipTool(player: Player, tool: Tool)
	pcall(function()
		local backpack = player:FindFirstChild 'Backpack' :: Backpack?
		warn(backpack and backpack:GetFullName())
		tool.Parent = backpack
	end)
end

function Module.player(tool: Tool): Player?
	local character = tool:FindFirstAncestorWhichIsA 'Model' :: Model?
	if character then
		local player = Players:GetPlayerFromCharacter(character) :: Player?
		if player then
			return player
		end
	end

	return tool:FindFirstAncestorWhichIsA 'Player'
end

export type Component = typeof(Module.tool.add(...))

return Module

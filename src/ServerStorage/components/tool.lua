local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local Tools = ReplicatedStorage.Tools

local Connect = require(ReplicatedStorage.connect)
local World = require(ReplicatedStorage.world)

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
	Module.factory.add(newTool)
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
		warn(backpack:GetFullName())
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

function Module.add(factory, entity: Tool)
	warn('add tool' .. entity.Name)

	local signals = {
		equipped = Instance.new 'BindableEvent',
		unequipped = Instance.new 'BindableEvent',
	}

	local connections = {}

	connections.equipped = entity.Equipped:Connect(function(mouse: Mouse)
		warn(entity:GetFullName())
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

		signals.equipped:Fire(entity, mouse)
	end)

	connections.unequipped = entity.Unequipped:Connect(function(mouse: Mouse)
		warn(entity:GetFullName())
		signals.unequipped:Fire(entity, mouse)
		Connect.disconnect(connections, 'died')
	end)

	return {
		signals = signals,
		connections = connections,
	}
end

function Module.remove(factory, entity: Tool, component: Component)
	warn('remove tool' .. entity.Name)
	Connect.disconnect(component.connections)
	Connect.disconnect(component.signals)
end

Module.factory = World.factory(script.Name, Module)

export type Component = typeof(Module.add(...))

return Module

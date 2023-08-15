--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerStorage = game:GetService 'ServerStorage'

local Connect = require(ReplicatedStorage.connect)

local Chase = require(ServerStorage.components.chase)
local Repel = require(ServerStorage.components.repel)
local World = require(ReplicatedStorage.world)

local Module = {}

Module.signals = {
	killed = Instance.new 'BindableEvent',
}

function Module.add(factory, entity: Model)
	local touchedConnections = {}

	local function killPlayer(player: Player, character: Model)
		local humanoid = character:FindFirstChildWhichIsA 'Humanoid' :: Humanoid?
		warn(humanoid)
		if not humanoid then
			return
		end

		if humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
			return
		end

		humanoid:TakeDamage(math.huge) -- This is where we get the behavior of enemies killing you when you touch them

		entity:Destroy()
	end

	for _, descendant in entity:GetDescendants() do
		if descendant:IsA 'BasePart' then
			table.insert(touchedConnections, Connect.playerTouched(descendant, killPlayer))
		end
	end

	task.defer(function()
		-- Though not true, I'll assume all enemies just follow the player
		Chase.factory.add(entity)

		-- And I want them to repel eachother
		Repel.factory.add(entity)
	end)

	return {
		touchedConnections = touchedConnections,
	}
end

function Module.remove(factory, entity: Model, enemy: Enemy)
	Connect.disconnect(enemy.touchedConnections)

	Repel.factory.remove(entity)
	Chase.factory.remove(entity)

	return nil
end

Module.factory = World.factory(script.Name, Module)

function Module.factory.removed(entity: Model, enemy: Enemy)
	Module.signals.killed:Fire(entity)
end

export type Enemy = typeof(Module.add(...))

return Module

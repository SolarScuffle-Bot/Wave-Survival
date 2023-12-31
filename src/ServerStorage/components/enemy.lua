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

Module.factory = World.factory(script.Name, {
	add = function(factory, entity: Model)
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

		return {
			touchedConnections = touchedConnections,
		}
	end,
	remove = function(factory, entity: Model, enemy: Component)
		Connect.disconnect(enemy.touchedConnections)

		Repel.factory.remove(entity)
		Chase.factory.remove(entity)

		return nil
	end,
})

function Module.factory.added(entity: Model, enemy: Component)
	-- Though not true, I'll assume all enemies just follow the player
	Chase.factory.add(entity)

	-- And I want them to repel eachother
	Repel.factory.add(entity)
end

function Module.factory.removed(entity: Model, enemy: Component)
	Module.signals.killed:Fire(entity)
end

export type Component = typeof(Module.factory.add(...))

return Module

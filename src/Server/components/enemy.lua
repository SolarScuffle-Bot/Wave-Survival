--!strict

local ServerScriptService = game:GetService 'ServerScriptService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Connect = require(ReplicatedStorage.connect)

local World = require(ServerScriptService.world)
local Chase = require(ServerScriptService.components.chase)
local Repel = require(ServerScriptService.components.repel)

local Module = {}

function Module.add(factory, entity: Model)
	local touchedConnections = {}

	for _, descendant in entity:GetDescendants() do
		if descendant:IsA 'BasePart' then
			table.insert(touchedConnections, Connect.playerTouched(descendant, function(player: Player, character: Model)
				local humanoid = character:FindFirstChildWhichIsA 'Humanoid' :: Humanoid?
				warn(humanoid)
				if not humanoid then
					return
				end

				humanoid:TakeDamage(math.huge)

				entity:Destroy()
			end))
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

export type Enemy = typeof(Module.add(...))

return Module
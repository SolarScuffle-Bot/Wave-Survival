--!strict

local ServerScriptService = game:GetService 'ServerScriptService'

local World = require(ServerScriptService.world)
local Chase = require(ServerScriptService.components.chase)
local Repel = require(ServerScriptService.components.repel)

local Module = {}

function Module.add(factory, entity: Model)
	task.defer(function()
		-- Though not true, I'll assume all enemies just follow the player
		Chase.factory.add(entity)

		-- And I want them to repel eachother
		Repel.factory.add(entity)
	end)

	return true
end

Module.factory = World.factory(script.Name, Module)

export type Enemy = typeof(Module.add(...))

return Module
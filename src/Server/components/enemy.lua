--!strict

local ServerScriptService = game:GetService 'ServerScriptService'
local World = require(ServerScriptService.world)
local Chase = require(ServerScriptService.components.chase)

local Module = {}

function Module.create(factory, entity: Model)
	task.defer(function()
		-- Though not true, I'll assume all enemies just follow the player
		Chase.factory.add(entity)
	end)

	return true
end

Module.factory = World.factory(script.Name, Module)

export type Enemy = typeof(Module.create(...))

return Module
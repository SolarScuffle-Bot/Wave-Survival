--!strict

local CollectionService = game:GetService 'CollectionService'
local ServerScriptService = game:GetService 'ServerScriptService'

local World = require(ServerScriptService.world)

local Module = {}

function Module.add(factory, entity: Model)
	CollectionService:AddTag(entity, 'Tool')
	return true
end

function Module.remove(factory, entity: Model)
	CollectionService:RemoveTag(entity, 'Tool')
	return true
end

Module.factory = World.factory(script.Name, Module)

return Module

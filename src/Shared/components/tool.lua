local CollectionService = game:GetService 'CollectionService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Connect = require(ReplicatedStorage.connect)

local World = require(ReplicatedStorage.world)

local Module = {}

function Module.add(factory, entity: Tool)
	warn('add tool' .. entity.Name)


end

function Module.remove(factory, entity: Tool, component: Component)
	warn('remove tool' .. entity.Name)

	
end

Module.factory = World.factory(script.Name, Module)

Module.added = CollectionService:GetInstanceAddedSignal('tool'):Connect(Module.factory.add)
Module.removed = CollectionService:GetInstanceRemovedSignal('tool'):Connect(Module.factory.remove)

export type Component = typeof(Module.add(...))

return Module

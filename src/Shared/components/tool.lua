local CollectionService = game:GetService 'CollectionService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Connect = require(ReplicatedStorage.connect)
local World = require(ReplicatedStorage.world)

local Module = {}

Module.factory = World.factory(script.Name, {
	add = function(factory, entity: Tool)
		
		return true
	end,

	remove = function(factory, entity: Tool, component: Component)
	end,
})

Module.added = CollectionService:GetInstanceAddedSignal(script.Name):Connect(Module.factory.add)
Module.removed = CollectionService:GetInstanceRemovedSignal(script.Name):Connect(Module.factory.remove)
for _, tool in CollectionService:GetTagged(script.Name) do
	Module.factory.add(tool)
end

export type Component = typeof(Module.factory.add(...))

return Module

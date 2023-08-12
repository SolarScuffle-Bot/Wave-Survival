local CollectionService = game:GetService 'CollectionService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local World = require(ReplicatedStorage.world)

local Module = {}

function Module.equip()

end

function Module.unequip()

end

function Module.add(factory, entity: Tool)
	warn('add tool')
end

function Module.remove(factory, entity: Tool)
	warn('remove tool')
end

Module.factory = World.factory(script.Name, Module)

Module.added = CollectionService:GetInstanceAddedSignal('Tool'):Connect(Module.factory.add)
Module.removed = CollectionService:GetInstanceRemovedSignal('Tool'):Connect(Module.factory.remove)

return Module
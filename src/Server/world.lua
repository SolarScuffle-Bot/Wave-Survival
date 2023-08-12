local CollectionService = game:GetService 'CollectionService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Packages = ReplicatedStorage:WaitForChild 'Packages'
local Stew = require(Packages.Stew)

local Connect = require(ReplicatedStorage.connect)

local world = Stew.world()

local entityConnections = {}

world.spawned:Connect(function(entity)
	if typeof(entity) == 'Instance' then
		entityConnections[entity] = entity.Destroying:Connect(function()
			Connect.disconnect(entityConnections, entity)
			world.kill(entity)
		end)

		CollectionService:AddTag(entity, 'Entity')
	end
end)

world.killed:Connect(function(entity)
	if typeof(entity) == 'Instance' then
		CollectionService:RemoveTag(entity, 'Entity')
	end
end)

world.added:Connect(function(factory, entity, component)
	if typeof(entity) == 'Instance' then
		CollectionService:AddTag(entity, factory.name)
	end
end)

world.removed:Connect(function(factory, entity, component)
	if typeof(entity) == 'Instance' then
		CollectionService:RemoveTag(entity, factory.name)
	end
end)

return world

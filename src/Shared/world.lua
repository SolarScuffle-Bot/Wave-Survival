local CollectionService = game:GetService 'CollectionService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Packages = ReplicatedStorage:WaitForChild 'Packages'
local Stew = require(Packages.Stew)

local Connect = require(ReplicatedStorage.connect)

local world = Stew.world()

local entityConnections = {}

function world.spawned(entity)
	if typeof(entity) == 'Instance' then
		entityConnections[entity] = entity.Destroying:Connect(function()
			Connect.disconnect(entityConnections, entity)
			world.kill(entity)
		end)

		CollectionService:AddTag(entity, 'Entity')
	end
end

function world.killed(entity)
	if typeof(entity) == 'Instance' then
		CollectionService:RemoveTag(entity, 'Entity')
	end
end

function world.added(factory, entity, component)
	if typeof(entity) == 'Instance' then
		CollectionService:AddTag(entity, factory.name)
	end
end

function world.removed(factory, entity, component)
	if typeof(entity) == 'Instance' then
		CollectionService:RemoveTag(entity, factory.name)
	end
end

return world

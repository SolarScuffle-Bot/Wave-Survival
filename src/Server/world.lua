local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Packages = ReplicatedStorage:WaitForChild 'Packages'
local Stew = require(Packages.Stew)

local Connect = require(ReplicatedStorage.connect)

local world = Stew.world()

local entityConnections = {}

world.spawned:Connect(function(entity: Model)
	entityConnections[entity] = entity.Destroying:Connect(function()
		Connect.disconnect(entityConnections, entity)
		world.kill(entity)
	end)
end)

return world
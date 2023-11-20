--!strict

local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerStorage = game:GetService 'ServerStorage'

local Schedules = require(ReplicatedStorage.schedules)

local Chase = require(ServerStorage.components.chase)
local World = require(ReplicatedStorage.world)

return Schedules.tick.job(function()
	local chaseEntities = World.query { Chase.factory }
	for entity: Model, data in chaseEntities do
		-- Get the nearest entity
		local origin = entity:GetPivot()
		local minDistance, target = math.huge, nil

		for _, player in Players:GetPlayers() do
			local character = player.Character :: Model
			if not character then
				continue
			end

			local distance = (origin.Position - character:GetPivot().Position).Magnitude
			if distance < minDistance then
				minDistance = distance
				target = character
			end
		end

		-- Actually chase it now
		local chase = data.chase :: Chase.Component
		if not target or minDistance > chase.range then
			Chase.setTarget(entity, nil)
			continue
		end

		Chase.setTarget(entity, target)
	end
end)

--!strict

local Players = game:GetService("Players")
local ServerScriptService = game:GetService 'ServerScriptService'

local Schedules = require(ServerScriptService.schedules)

local World = require(ServerScriptService.world)
local Chase = require(ServerScriptService.components.chase)

return Schedules.tick.job(function()
	for entity: Model, data in World.query { Chase.factory } do
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

		local chase = data.chase :: Chase.Chase
		if not target or minDistance > chase.range then
			Chase.setTarget(entity, nil)
			continue
		end

		Chase.setTarget(entity, target)
	end
end)
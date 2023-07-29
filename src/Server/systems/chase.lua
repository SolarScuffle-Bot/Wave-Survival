local Players = game:GetService("Players")
local ServerScriptService = game:GetService 'ServerScriptService'

local Schedules = require(ServerScriptService.schedules)
local World = require(ServerScriptService.world)
local Chase = require(ServerScriptService.components.chase)

local Module = {}

Module.range = 40

Module.job = Schedules.heartbeat.job(function()
	for entity: Model, data in World.query { Chase.factory } do
		local origin = entity:GetPivot()
		local minDistance, target = math.huge, nil

		for _, player in Players:GetPlayers() do
			local character = player.Character
			if not character then
				continue
			end

			local distance = (origin.Position - character:GetPivot().Position).Magnitude
			if distance < minDistance then
				minDistance = distance
				target = character
			end
		end

		if not target or minDistance > Module.range then
			Chase.setTarget(entity, nil)
			continue
		end

		Chase.setTarget(entity, target)
	end
end)

return Module
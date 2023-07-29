local ServerScriptService = game:GetService 'ServerScriptService'

local Schedules = require(ServerScriptService.schedules)
local World = require(ServerScriptService.world)
local Follow = require(ServerScriptService.components.follow)
local Repel = require(ServerScriptService.components.repel)
local FollowSystem = require(ServerScriptService.systems.follow)

local Module = {}

Module.job = Schedules.heartbeat.job(function()
	local repels = World.query { Repel.factory, Follow.factory }
	for entity: Model, data in repels do
		local origin = entity:GetPivot()

		for other: Model, otherData in repels do
			if entity == other then
				continue
			end

			local otherOrigin = other:GetPivot()
			local delta = origin.Position - otherOrigin.Position
			if delta.Magnitude > data.repel.range then
				continue
			end

			local force = delta.Unit * data.repel.force
			otherData.follow.linearVelocity.VectorVelocity += force
		end
	end
end, FollowSystem.job)

return Module
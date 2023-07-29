local ServerScriptService = game:GetService 'ServerScriptService'

local Schedules = require(ServerScriptService.schedules)
local World = require(ServerScriptService.world)
local Follow = require(ServerScriptService.components.follow)

local Module = {}

Module.speed = 10

Module.job = Schedules.heartbeat.job(function()
	for entity: Model, data in World.query { Follow.factory } do
		local follow = data.follow :: Follow.Follow

		local there = follow.target:GetPivot()
		local here = entity:GetPivot()

		local targetDelta = (there.Position - here.Position).Unit
		local targetRotation = (here:Inverse() * there).Rotation

		follow.linearVelocity.VectorVelocity = targetDelta * Module.speed
		follow.alignOrientation.CFrame = targetRotation
	end
end)

return Module
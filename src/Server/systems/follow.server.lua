--!strict

local ServerScriptService = game:GetService 'ServerScriptService'

local Schedules = require(ServerScriptService.schedules)

local World = require(ServerScriptService.world)
local Follow = require(ServerScriptService.components.follow)
local Move = require(ServerScriptService.components.move)

return Schedules.tick.job(function()
	for entity: Model, data in World.query { Follow.factory, Move.factory } do
		local follow = data.follow :: Follow.Follow

		local there = follow.target:GetPivot()
		local here = entity:GetPivot()

		local trx, try, trz = CFrame.lookAt(here.Position, there.Position):ToEulerAnglesYXZ()

		local move = data.move :: Move.Move

		move.linearVelocity.VectorVelocity = -Vector3.zAxis * follow.speed
		move.alignOrientation.CFrame = CFrame.fromEulerAnglesYXZ(trx, try, trz + math.pi / 2)
	end
end)
--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerStorage = game:GetService 'ServerStorage'

local Schedules = require(ServerStorage.schedules)

local Follow = require(ServerStorage.components.follow)
local Move = require(ServerStorage.components.move)
local World = require(ReplicatedStorage.world)

return Schedules.tick.job(function()
	for entity: Model, data in World.query { Follow.factory, Move.factory } do
		local follow = data.follow :: Follow.Component

		local there = follow.target:GetPivot()
		local here = entity:GetPivot()

		local trx, try, trz = CFrame.lookAt(here.Position, there.Position):ToEulerAnglesYXZ()

		local move = data.move :: Move.Component

		move.linearVelocity.VectorVelocity = -Vector3.zAxis * follow.speed
		move.alignOrientation.CFrame = CFrame.fromEulerAnglesYXZ(trx, try, trz + math.pi / 2)
	end
end)

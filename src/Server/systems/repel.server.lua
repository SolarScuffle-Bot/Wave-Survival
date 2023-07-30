--!strict

local ServerScriptService = game:GetService 'ServerScriptService'

local Schedules = require(ServerScriptService.schedules)

local World = require(ServerScriptService.world)
local Move = require(ServerScriptService.components.move)
local Repel = require(ServerScriptService.components.repel)

return Schedules.tick.job(function(deltaTime: number)
	local repels = World.query { Repel.factory, Move.factory }
	for entity: Model, data in repels do
		local repel = data.repel :: Repel.Repel

		local move = data.move :: Move.Move
		local origin = move.attachment.WorldCFrame

		local force = Vector3.zero
		local forceScale = move.linearVelocity.MaxForce

		for other: Model, otherData in repels do
			if entity == other then
				continue
			end

			local otherMove = otherData.move :: Move.Move
			local otherOrigin = otherMove.attachment.WorldCFrame
			local delta = origin.Position - otherOrigin.Position
			if delta.Magnitude >= 1 then
				force += delta.Unit * forceScale * Repel.force(repel, delta.Magnitude)
			end
		end

		if force.Magnitude < 1e-5 then
			repel.vectorForce.Force = Vector3.zero
			continue
		end

		force = force.Unit * math.min(force.Magnitude, forceScale * repel.maxForce)
		repel.vectorForce.Force = force
	end
end)
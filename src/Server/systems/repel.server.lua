--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerStorage = game:GetService 'ServerStorage'

local Schedules = require(ReplicatedStorage.schedules)

local Move = require(ServerStorage.components.move)
local Repel = require(ServerStorage.components.repel)
local World = require(ReplicatedStorage.world)

local repels = World.query { Repel.factory, Move.factory }

return Schedules.tick.job(function(deltaTime: number)
	for entity: Model, data in repels do
		local repel = data.repel :: Repel.Component
		local move = data.move :: Move.Component
		local origin = move.attachment.WorldCFrame

		local force = Vector3.zero
		local forceScale = move.linearVelocity.MaxForce

		-- sorry no, Chase 30hz -> Follow 60hz -> Repel 3hz -- This doesn't seem like bad design, but it doesn't compute :sad:
		-- Maybe there has to be a restriction, to depend on a previous job, it has to have the same frequency
		-- Create / destroy / update, same thing

		for other: Model, otherData in repels do
			if entity == other then
				continue
			end

			local otherMove = otherData.move :: Move.Component
			local otherOrigin = otherMove.attachment.WorldCFrame
			local delta = origin.Position - otherOrigin.Position
			if delta.Magnitude >= 1 then
				force += delta.Unit * forceScale * Repel.force(repel, delta.Magnitude)
			end
		end

		-- Floating point numbers suck, so don't let it get crazy
		if force.Magnitude < 1e-5 then
			repel.vectorForce.Force = Vector3.zero
			continue
		end

		force = force.Unit * math.min(force.Magnitude, forceScale * repel.maxForce)
		repel.vectorForce.Force = force
	end
end)

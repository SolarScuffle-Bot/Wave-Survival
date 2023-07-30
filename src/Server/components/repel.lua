--!strict

local ServerScriptService = game:GetService 'ServerScriptService'

local World = require(ServerScriptService.world)
local Move = require(ServerScriptService.components.move)

local function newVectorForce(attachment: Attachment)
	local vectorForce = Instance.new 'VectorForce'
	vectorForce.Force = Vector3.zero
	vectorForce.RelativeTo = Enum.ActuatorRelativeTo.World
	-- vectorForce.ApplyAtCenterOfMass = true
	vectorForce.Attachment0 = attachment

	return vectorForce
end

local Module = {}

function Module.force(repel: Repel, distance: number)
	local numerator = repel.range * (repel.threshold - distance)
	local denominator = repel.threshold * (repel.threshold + distance)
	return math.max(0, repel.force * numerator / denominator)
end

function Module.add(factory, entity: Model, settings: {
	range: number?,
	force: number?,
	threshold: number?,
}?)
	local entityPrimary = entity.PrimaryPart
	if not entityPrimary then
		error('No primary part found for entity ' .. entity:GetFullName())
	end

	local move = World.get(entity).move :: Move.Move?
	if not move then
		error('No move component found for entity ' .. entity:GetFullName())
	end

	local vectorForce = newVectorForce(move.attachment)
	vectorForce.Parent = entityPrimary

	local range = settings and settings.range or 20
	local force = settings and settings.force or 2
	local threshold = settings and settings.threshold or range

	return {
		range = range,
		force = force,
		threshold = threshold,
		vectorForce = vectorForce,
		vectorDestroying = vectorForce.Destroying:Connect(function()
			factory.remove(entity)
		end),
	}
end

function Module.remove(factory, entity: Model, repel: Repel)
	repel.vectorDestroying:Disconnect()
	repel.vectorForce:Destroy()
	return nil
end

Module.factory = World.factory(script.Name, Module)

export type Repel = typeof(Module.add(...))

return Module
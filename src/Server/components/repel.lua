--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerScriptService = game:GetService 'ServerScriptService'

local Move = require(ServerScriptService.components.move)
local World = require(ServerScriptService.world)

local Connect = require(ReplicatedStorage.connect)

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
	--? https://www.desmos.com/calculator/mzydp6ugtp

	local numerator = repel.range * (repel.threshold - distance)
	local denominator = repel.threshold * (repel.threshold + distance)
	return math.max(0, repel.force * numerator / denominator)
end

function Module.add(
	factory,
	entity: Model,
	settings: {
		range: number?,
		force: number?,
		maxForce: number?,
		threshold: number?,
	}?
)
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
	local force = settings and settings.force or 1.5
	local maxForce = settings and settings.maxForce or 5
	local threshold = settings and settings.threshold or range

	return {
		range = range,
		force = force,
		maxForce = maxForce,
		threshold = threshold,
		vectorForce = vectorForce,
		vectorDestroying = vectorForce.Destroying:Connect(function()
			factory.remove(entity)
		end),
	}
end

function Module.remove(factory, entity: Model, repel: Repel)
	Connect.disconnect(repel)
	return nil
end

Module.factory = World.factory(script.Name, Module)

export type Repel = typeof(Module.add(...))

return Module

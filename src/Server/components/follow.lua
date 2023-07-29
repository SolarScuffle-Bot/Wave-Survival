--!strict

local ServerScriptService = game:GetService 'ServerScriptService'
local World = require(ServerScriptService.world)

local Module = {}

function Module.create(factory, entity: Model, target: Model)
	local entityPrimary = entity.PrimaryPart
	if not entityPrimary then
		error('No primary part found for entity ' .. entity:GetFullName())
	end

	local targetPrimary = target.PrimaryPart
	if not targetPrimary then
		error('No primary part found for target ' .. target:GetFullName())
	end

	local linearVelocity = entityPrimary:FindFirstChildWhichIsA('LinearVelocity')
	if not linearVelocity then
		error('No linear velocity found for entity ' .. entity:GetFullName())
	end

	local alignOrientation = entityPrimary:FindFirstChildWhichIsA('AlignOrientation')
	if not alignOrientation then
		error('No align orientation found for entity ' .. entity:GetFullName())
	end

	local entityAttachment = entityPrimary:FindFirstChildWhichIsA('Attachment')
	if not entityAttachment then
		error('No attachment found for entity ' .. entity:GetFullName())
	end

	if not target.Parent then
		error('Target must be parented to the world')
	end

	return {
		linearVelocity = linearVelocity,
		alignOrientation = alignOrientation,
		target = target,
		targetDestroying = target.Destroying:Connect(function()
			factory.remove(entity)
		end),
	}
end

function Module.delete(factory, entity: Model, follow: Follow)
	follow.targetDestroying:Disconnect()
	return nil
end

Module.factory = World.factory(script.Name, Module)

export type Follow = typeof(Module.create(...))

return Module
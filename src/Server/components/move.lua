--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService 'ServerScriptService'
local World = require(ServerScriptService.world)

local Connect = require(ReplicatedStorage.connect)

local Module = {}

local function newAttachment()
	local attachment = Instance.new 'Attachment'
	attachment.Axis = Vector3.yAxis
	attachment.SecondaryAxis = -Vector3.xAxis
	return attachment
end

local function newLinerVelocity(attachment: Attachment)
	local linearVelocity = Instance.new 'LinearVelocity'
	linearVelocity.Name = 'LinearVelocity'
	linearVelocity.MaxForce = 5000
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
	linearVelocity.Attachment0 = attachment

	return linearVelocity
end

local function newAlignOrientation(attachment: Attachment)
	local alignOrientation = Instance.new 'AlignOrientation'
	alignOrientation.MaxTorque = 5000
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.PrimaryAxis = Vector3.yAxis
	alignOrientation.SecondaryAxis = -Vector3.xAxis
	alignOrientation.ReactionTorqueEnabled = true
	alignOrientation.Attachment0 = attachment

	return alignOrientation
end

function Module.add(factory: typeof(Module.factory), entity: Model)
	local entityPrimary = entity.PrimaryPart
	if not entityPrimary then
		error('No primary part found for entity ' .. entity:GetFullName())
	end

	local attachment = newAttachment()
	attachment.Parent = entityPrimary

	local linearVelocity = newLinerVelocity(attachment)
	linearVelocity.Parent = entityPrimary

	local alignOrientation = newAlignOrientation(attachment)
	alignOrientation.Parent = entityPrimary

	return {
		attachment = attachment,
		linearVelocity = linearVelocity,
		alignOrientation = alignOrientation,
		linearDestroying = linearVelocity.Destroying:Connect(function()
			factory.remove(entity)
		end),
		alignDestroying = alignOrientation.Destroying:Connect(function()
			factory.remove(entity)
		end),
	}
end

function Module.remove(factory, entity: Model, move: Move)
	Connect.disconnect(move)
	-- move.linearDestroying:Disconnect()
	-- move.alignDestroying:Disconnect()

	-- pcall(function()
	-- 	move.attachment:Destroy()
	-- end)

	-- pcall(function()
	-- 	move.linearVelocity:Destroy()
	-- end)

	-- pcall(function()
	-- 	move.alignOrientation:Destroy()
	-- end)

	return nil
end

Module.factory = World.factory(script.Name, Module)

export type Move = typeof(Module.add(...))

return Module

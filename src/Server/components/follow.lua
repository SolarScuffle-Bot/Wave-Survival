local ServerScriptService = game:GetService 'ServerScriptService'
local worlds = require(ServerScriptService.worlds)

local module = {}

function module.update(follow: Follow)
	local target = follow.target
	local targetPosition = target.Position
	local targetOrientation = target.Orientation
	local targetVelocity = target.Velocity

	local linearVelocity = follow.linearVelocity
	local alignOrientation = follow.alignOrientation

	linearVelocity.Target = targetPosition
	alignOrientation.Target = targetOrientation
end

function module.Constructor(entity: any, name: string, target: PVInstance)
	local primary = entity.PrimaryPart
	if not primary then
		error('No primary part found for entity ' .. entity:GetFullName())
	end

	local linearVelocity = primary:FindFirstAncestorWhichIsA('LinearVelocity')
	if not linearVelocity then
		error('No linear velocity found for entity ' .. entity:GetFullName())
	end

	local alignOrientation = primary:FindFirstAncestorWhichIsA('AlignOrientation')
	if not alignOrientation then
		error('No align orientation found for entity ' .. entity:GetFullName())
	end

	if not target.Parent then
		error('Target must be parented to the world')
	end

	return {
		linearVelocity = linearVelocity,
		alignOrientation = alignOrientation,
		target = target,
		targetDestorying = target.Destroying:Connect(function()
			worlds.Component.Delete(entity, name)
		end),
	}
end

function module.Destructor(entity, name: string)
	local follow = worlds.Component.Get(entity, name)
	follow.targetDestorying:Disconnect()
end

worlds.Component.Build(script.Name, module)

export type Follow = typeof(module.Constructor())

return module
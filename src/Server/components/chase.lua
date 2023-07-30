--!strict

local ServerScriptService = game:GetService 'ServerScriptService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local World = require(ServerScriptService.world)
local Follow = require(ServerScriptService.components.follow)

local Connect = require(ReplicatedStorage.connect)

local Module = {}

function Module.setTarget(entity: Model, target: Model?)
	local chase = World.get(entity).chase :: Chase?
	if not chase then
		return
	end

	if chase.target == target then
		return
	end

	if chase.target then
		Connect.disconnect(chase, 'destroyed')
		Connect.disconnect(chase, 'died')
		Follow.factory.remove(entity)
	end

	if target then
		local function stop()
			Module.setTarget(entity, nil)
		end

		chase.target = target
		chase.destroyed = target.Destroying:Connect(stop)

		local humanoid = target:FindFirstChildWhichIsA('Humanoid', true) :: Humanoid?
		if humanoid then
			chase.died = humanoid.Died:Connect(stop)
		end

		Follow.factory.add(entity, target)
	end
end

function Module.add(factory, entity: Model, model: Model, settings: {
	range: number?,
	linearSpeed: number?,
	angularSpeed: number?,
}?)
	return {
		range = settings and settings.range or math.huge,
		linearSpeed = settings and settings.linearSpeed or 10,
		angularSpeed = settings and settings.angularSpeed or 10,
		target = nil :: Model?,
		destroyed = nil :: RBXScriptConnection?,
		died = nil :: RBXScriptConnection?,
	}
end

function Module.remove(factory, entity: Model, chase: Chase) -- remove cleans it up
	Module.setTarget(entity, nil)
	return nil
end

Module.factory = World.factory(script.Name, Module)

export type Chase = typeof(Module.add(...))

return Module
--!strict

local ServerScriptService = game:GetService 'ServerScriptService'
local World = require(ServerScriptService.world)
local Follow = require(ServerScriptService.components.follow)

local Module = {}

function Module.setTarget(entity: Model, target: Model?)
	local chase = World.get(entity).chase :: Chase

	if chase.target == target then
		return
	end

	if chase.destroyed then
		chase.destroyed:Disconnect()
		chase.destroyed = nil
		chase.target = nil

		Follow.factory.remove(entity)
	end

	if target then
		chase.target = target
		chase.destroyed = target.Destroying:Connect(function()
			Module.setTarget(entity, nil)
		end)

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
	}
end

function Module.remove(factory, entity: Model, chase: Chase)
	Module.setTarget(entity, nil)
	return nil
end

Module.factory = World.factory(script.Name, Module)

export type Chase = typeof(Module.add(...))

return Module
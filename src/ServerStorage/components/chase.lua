--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerStorage = game:GetService 'ServerStorage'

local Follow = require(ServerStorage.components.follow)
local World = require(ReplicatedStorage.world)

local Connect = require(ReplicatedStorage.connect)

local Module = {}

function Module.setTarget(entity: Model, target: Model?)
	local chase = World.get(entity).chase :: Component?
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

Module.factory = World.factory(script.Name, {
	add = function(
		factory,
		entity: Model,
		settings: {
			range: number?,
			linearSpeed: number?,
			angularSpeed: number?,
		}?
	)
		return {
			range = settings and settings.range or math.huge,
			linearSpeed = settings and settings.linearSpeed or 10,
			angularSpeed = settings and settings.angularSpeed or 10,
			target = nil :: Model?,
			destroyed = nil :: RBXScriptConnection?,
			died = nil :: RBXScriptConnection?,
		}
	end,

	remove = function(factory, entity: Model, chase: Component)
		Module.setTarget(entity, nil)
	end,
})

export type Component = typeof(Module.factory.add(...))

return Module

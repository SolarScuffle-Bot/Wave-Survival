--!strict

local ServerScriptService = game:GetService 'ServerScriptService'
local World = require(ServerScriptService.world)
local Move = require(ServerScriptService.components.move)

local Module = {}

function Module.add(factory, entity: Model, target: Model, speed: number?)
	return {
		speed = speed or 10,
		target = target,
		targetDestroying = target.Destroying:Connect(function()
			factory.remove(entity)
		end),
	}
end

function Module.remove(factory, entity: Model, follow: Follow)
	follow.targetDestroying:Disconnect()

	local move = World.get(entity).move :: Move.Move?
	if move then
		move.linearVelocity.VectorVelocity = Vector3.zero
	end

	return nil
end

Module.factory = World.factory(script.Name, Module)

export type Follow = typeof(Module.add(...))

return Module

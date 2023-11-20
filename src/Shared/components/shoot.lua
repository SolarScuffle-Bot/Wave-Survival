local ContextActionService = game:GetService 'ContextActionService'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local World = require(ReplicatedStorage.world)

local Module = {}

Module.signals = {
	fire = Instance.new 'BindableEvent',
}

Module.factory = World.factory(script.Name, {
	add = function(factory, entity: Instance)
		return true
	end,

	remove = function(factory, entity: Instance, component: Component) end,
})

export type Component = typeof(Module.factory.add(...))

return Module

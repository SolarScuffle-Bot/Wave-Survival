local ServerScriptService = game:GetService 'ServerScriptService'
local World = require(ServerScriptService.world)

local Module = {}

function Module.create(factory, entity: Model, range: number?, force: number?)
	return {
		range = range or 40,
		force = force or 100,
	}
end

Module.factory = World.factory(script.Name, Module)

export type Repel = typeof(Module.create(...))

return Module
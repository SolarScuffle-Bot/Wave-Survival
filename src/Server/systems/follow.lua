local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService 'ServerScriptService'

local schedules = require(ServerScriptService.schedules)
local worlds = require(ServerScriptService.worlds)

return schedules.heartbeat.new(function()
	for entity in worlds.Collection.Get {'enemy', 'follow'} do
		-- local enemy =  worlds.Component.Get(entity, 'enemy')
		local follow = worlds.Component.Get(entity, 'follow')

		local linearVelocity = follow.linearVelocity :: LinearVelocity
		linearVelocity.VectorVelocity = Vector3.new(1, 0, 1) * math.random() * 100

		local alignOrientation = follow.alignOrientation :: AlignOrientation
		alignOrientation.Target = Vector3.yAxis * math.random() * 2 * math.pi
	end
end)
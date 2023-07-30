local ServerScriptService = game:GetService 'ServerScriptService'
local RunService = game:GetService 'RunService'

local Schedules = require(ServerScriptService.schedules)

local systems = {}
for _, system: ModuleScript in ServerScriptService.systems:GetChildren() do
	systems[system.Name] = require(system)
	warn(system.Name, systems[system.Name])
end

do
	systems.spawnEnemies.startRound()
end

do
	RunService.Heartbeat:Connect(Schedules.heartbeat.start)
end

do
	local TICKS_PER_SECOND = 3 --? Surprisingly more than enough!

	local tickBuffer = 0
	RunService.Heartbeat:Connect(function(deltaTime: number)
		tickBuffer += deltaTime
		if tickBuffer >= 1 / TICKS_PER_SECOND then
			Schedules.tick.start(tickBuffer)
			tickBuffer = 0
		end
	end)
end

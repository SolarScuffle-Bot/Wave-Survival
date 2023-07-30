--!strict

local ServerScriptService = game:GetService 'ServerScriptService'

do
	local SpawnEnemies = require(ServerScriptService.systems.spawnEnemies)
	SpawnEnemies.startRound()
end

local RunService = game:GetService 'RunService'
local Schedules = require(ServerScriptService.schedules)

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

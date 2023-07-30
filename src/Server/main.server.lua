--!strict

local ServerScriptService = game:GetService 'ServerScriptService'

do
	local SpawnEnemies = require(ServerScriptService.services.spawnEnemies)
	SpawnEnemies.startRound()
end

do
	local Players = game:GetService 'Players'
	local ToolService = require(ServerScriptService.services.tool)

	local function playerAdded(player: Player)
		player.CharacterAdded:Connect(function(character: Model)
			ToolService.giveTool(player, 'Sniper')
		end)
	end

	for _, player in Players:GetPlayers() do
		playerAdded(player)
	end
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

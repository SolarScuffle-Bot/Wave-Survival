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

		if player.Character then
			ToolService.giveTool(player, 'Sniper')
		end
	end

	Players.PlayerAdded:Connect(playerAdded)

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
	local TICK_FREQUENCY = 3 --? Surprisingly more than enough!
	local TICK_PERIOD = 1 / TICK_FREQUENCY

	local tickBuffer = 0
	RunService.Heartbeat:Connect(function(deltaTime: number)
		tickBuffer += deltaTime
		if tickBuffer >= TICK_PERIOD then
			Schedules.tick.start(tickBuffer)
			tickBuffer %= TICK_PERIOD
		end
	end)
end

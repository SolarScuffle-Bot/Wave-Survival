local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Connect = require(ReplicatedStorage.connect)
local States = require(ReplicatedStorage.states)

local ToolService = require(ServerStorage.util.tool)

local connections = {} :: {
	playerAdded: RBXScriptConnection?,
	playerRemvoing: RBXScriptConnection?,
	[Player]: RBXScriptConnection?,
}

local function playerAdded(player: Player)
	local function characterAdded(character: Model)
		ToolService.giveTool(player, 'Sniper')
	end

	connections[player] = player.CharacterAdded:Connect(characterAdded)

	if player.Character then
		characterAdded(player.Character)
	end
end

local function playerRemoving(player: Player)
	ToolService.removeTool(player, 'Sniper')
end

local function start()
	connections.playerAdded = Players.PlayerAdded:Connect(playerAdded)
	connections.playerRemvoing = Players.PlayerRemoving:Connect(playerRemoving)

	for _, player in Players:GetPlayers() do
		playerAdded(player)
	end
end

local function stop()
	Connect.disconnect(connections)

	for _, player in Players:GetPlayers() do
		playerRemoving(player)
	end
end

States.connect(States.states.waves, start, stop)
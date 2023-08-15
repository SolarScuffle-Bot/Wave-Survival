--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerStorage = game:GetService 'ServerStorage'

local Connect = require(ReplicatedStorage.connect)
local Data = require(ReplicatedStorage.data)
local States = require(ReplicatedStorage.states)

local Enemy = require(ServerStorage.components.enemy)
local Move = require(ServerStorage.components.move)
local Repel = require(ServerStorage.components.repel)

local EnemiesFolder = ReplicatedStorage:FindFirstChild 'Enemies' :: Folder?
assert(EnemiesFolder, 'Enemies folder not found in ReplicatedStorage')

local Gooblet = EnemiesFolder:FindFirstChild 'Gooblet' :: Model?
assert(Gooblet, 'Gooblet model not found in Enemies folder')

local Goobler = EnemiesFolder:FindFirstChild 'Goobler' :: Model?
assert(Goobler, 'Goobler model not found in Enemies folder')

local currentCount = 0
local connections = {
	roundThread = nil :: thread?,
	enemyDied = nil :: RBXScriptConnection?,
}

local function spawnEnemies()
	currentCount = Data.waves.count

	for i = 1, currentCount do
		task.wait(0.1)

		local entity = Gooblet:Clone() :: Model
		entity:PivotTo(entity:GetPivot() * CFrame.new(10 * i, 10 * i, 10 * i))

		Move.factory.add(entity)
		Enemy.factory.add(entity)
		Repel.factory.add(entity)

		entity.Parent = workspace

		print('spawning enemy', i, entity:GetFullName())
	end

	connections.roundThread = nil
end

local function startRound()
	connections.roundThread = task.defer(spawnEnemies)
end

local function start()
	connections.enemyDied = Enemy.signals.killed.Event:Connect(function(entity: Model, enemy: Enemy.Component)
		currentCount -= 1
		if currentCount <= 0 then
			task.wait(5)
			startRound()
		end
	end)

	startRound()
end

local function stop()
	Connect.disconnect(connections)
	currentCount = 0
end

States.connect(States.states.waves, start, stop)
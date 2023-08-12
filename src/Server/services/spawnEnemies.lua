--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerScriptService = game:GetService 'ServerScriptService'

local Enemy = require(ServerScriptService.components.enemy)
local Move = require(ServerScriptService.components.move)
local Repel = require(ServerScriptService.components.repel)

local EnemiesFolder = ReplicatedStorage:FindFirstChild 'Enemies' :: Folder?
assert(EnemiesFolder, 'Enemies folder not found in ReplicatedStorage')

local Gooblet = EnemiesFolder:FindFirstChild 'Gooblet' :: Model?
assert(Gooblet, 'Gooblet model not found in Enemies folder')

local Goobler = EnemiesFolder:FindFirstChild 'Goobler' :: Model?
assert(Goobler, 'Goobler model not found in Enemies folder')

local Module = {}

Module.enemyCount = 100
Module.roundThread = nil :: thread?
Module.currentCount = 0

local function spawnEnemies()
	Module.currentCount = Module.enemyCount

	for i = 1, Module.currentCount do
		task.wait(0.1)

		local entity = Gooblet:Clone() :: Model
		entity:PivotTo(entity:GetPivot() * CFrame.new(10 * i, 10 * i, 10 * i))

		Move.factory.add(entity)
		Enemy.factory.add(entity)
		Repel.factory.add(entity)

		entity.Parent = workspace

		print('spawning enemy', i, entity:GetFullName())
	end

	Module.roundThread = nil
end

function Module.startRound()
	Module.roundThread = task.defer(spawnEnemies)
end

Module.added = Enemy.factory.removed:Connect(function(entity: Model, enemy: Enemy.Enemy)
	Module.currentCount -= 1
	if Module.currentCount <= 0 then
		task.wait(5)
		Module.startRound()
	end
end)

return Module
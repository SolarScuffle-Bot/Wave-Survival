local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerScriptService = game:GetService 'ServerScriptService'
local Enemy = require(ServerScriptService.components.enemy)
local Repel = require(ServerScriptService.components.repel)

local Enemies = ReplicatedStorage.Enemies

local Module = {}

Module.count = 0

function Module.startRound()
    Module.roundThread = task.defer(function()
        Module.count = 10

        for i = 1, Module.count do
            task.wait(1)

            local entity = Enemies.Gooblet:Clone()
            entity.Parent = workspace

            Enemy.factory.add(entity)
            Repel.factory.add(entity)

            print('spawning enemy', i, entity:GetFullName())
        end

        Module.roundThread = nil
    end)
end

Module.added = Enemy.factory.removed:Connect(function()
    Module.count -= 1
    if Module.count <= 0 then
        task.wait(5)
        Module.startRound()
    end
end)

return Module

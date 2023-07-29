local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerScriptService = game:GetService 'ServerScriptService'

local schedules = require(ServerScriptService.schedules)
local worlds = require(ServerScriptService.worlds)

local spawning = false
local lastSpawnTime = 0

return schedules.heartbeat.new(function(dt: number)
	local enemyCount = #worlds.Collection.Get { 'enemy' }
    if enemyCount == 0 then
        spawning = true
    elseif enemyCount == 10 then
        spawning = false
    end

    if spawning then
        local now = time()
        if now - lastSpawnTime > 0.5 then
            lastSpawnTime = now
            local entity = worlds.Entity.Create()
            worlds.Component.Create(entity, "enemy")
        end
    end
end)

local ServerScriptService = game:GetService 'ServerScriptService'
local RunService = game:GetService 'RunService'

local Schedules = require(ServerScriptService.schedules)

local systems = {}
for _, system: ModuleScript in ServerScriptService.systems:GetChildren() do
	systems[system.Name] = require(system)
	warn(system.Name, systems[system.Name])
end

systems.spawnEnemies.startRound()

RunService.Heartbeat:Connect(Schedules.heartbeat.start)
local ServerScriptService = game:GetService 'ServerScriptService'
local RunService = game:GetService 'RunService'

local schedules = require(ServerScriptService.schedules)
local worlds = require(ServerScriptService.worlds)

RunService.Heartbeat:Connect(schedules.heartbeat.start)
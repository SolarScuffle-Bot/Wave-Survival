local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local RunService = game:GetService 'RunService'

local Packages = ReplicatedStorage:WaitForChild 'Packages'
local sandwich = require(Packages.sandwich)

local module = {}

module.heartbeat = sandwich.new()

RunService.Heartbeat:Connect(function(dt)
	module.heartbeat.start(dt)
end)

return module

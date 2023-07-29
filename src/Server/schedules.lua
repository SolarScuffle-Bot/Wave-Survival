local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local Packages = ReplicatedStorage:WaitForChild 'Packages'
local Sandwich = require(Packages.Sandwich)

local Module = {}

Module.heartbeat = Sandwich.schedule()

return Module

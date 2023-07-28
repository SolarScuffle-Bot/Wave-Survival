local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Packages = ReplicatedStorage:WaitForChild 'Packages'
local sandwich = require(Packages.sandwich)

local module = {}

module.heartbeat = sandwich.new()

return module

local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Packages = ReplicatedStorage:WaitForChild 'Packages'
local Stew = require(Packages.Stew)

local world = Stew.world()

return world
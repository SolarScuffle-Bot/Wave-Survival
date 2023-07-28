local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Packages = ReplicatedStorage:WaitForChild 'Packages'
local stew = require(Packages.stew)

return stew.World.Create()
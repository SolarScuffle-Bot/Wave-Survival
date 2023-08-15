local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local RunService = game:GetService 'RunService'

local function taco(name: string)
	if RunService:IsServer() then
		local remote = Instance.new 'RemoteEvent'
		remote.Name = name
		remote.Parent = ReplicatedStorage
		return remote
	else
		return ReplicatedStorage:WaitForChild(name)
	end
end

local Module = {}

-- Start simple, then complicate where necessary
Module.sniper = taco 'Sniper'

return Module

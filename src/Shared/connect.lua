--!strict

local Players = game:GetService 'Players'
local ReplicatedStorage = game:GetService 'ReplicatedStorage'

--[=[
	@class Connect
	Connect is a utility that provides the boilerplate often found when connecting to events and signals
]=]
local Module = {}

local function onPlayerTouched(callback: (player: Player, character: Model) -> ())
	return function(otherPart: BasePart)
		local otherPlayer, otherCharacter = Module.getPlayerFromPart(otherPart)
		if otherPlayer and otherCharacter then
			callback(otherPlayer, otherCharacter)
		end
	end
end

--[=[
	@within Connect
	Returns if the basepart is a descendant of a player's character
]=]
function Module.getPlayerFromPart(basePart: BasePart): (Player?, Model?)
	local character = basePart:FindFirstAncestorWhichIsA 'Model'
	if not character then
		return nil, nil
	end

	return Players:GetPlayerFromCharacter(character), character
end

--[=[
	@within Connect
	Connects a function to a signal that is called when a player touches a part
]=]
function Module.playerTouched(part: BasePart, callback: (player: Player, character: Model) -> ())
	return part.Touched:Connect(onPlayerTouched(callback))
end

--[=[
	@within Connect
	Connects a function to a signal that is called when a player stops touching a part
]=]
function Module.playerTouchEnded(part: BasePart, callback: (player: Player, character: Model) -> ())
	return part.TouchEnded:Connect(onPlayerTouched(callback))
end

--[=[
	@within Connect
	Connects a function to a signal that is called when a player left clicks a click detector
]=]
function Module.playerClicked(detector: ClickDetector, callback: (player: Player) -> ())
	return detector.MouseClick:Connect(callback)
end

export type Connection = RBXScriptConnection | { Disconnect: (any) -> () } | thread | Instance

local function disconnect(connection: Connection)
	if type(connection) == 'thread' then
		task.cancel(connection)
	elseif typeof(connection) == 'Instance' then
		pcall(connection.Destroy, connection)
	elseif type(connection) == 'function' then
		connection()
	elseif type(connection) == 'table' and type(connection.Disconnect) == 'function' then
		connection:Disconnect()
	end
end

--[=[
	@within Connect
	Removes connections from a table (recursively), or disconnects a single connection.
]=]
function Module.disconnect<T>(connections: { [T]: Connection }, key: T?)
	if key then
		local connection = connections[key]
		if connection then
			disconnect(connection)
			connections[key] = nil
		end
	else
		for _, connection in connections do
			disconnect(connection)
		end

		table.clear(connections)
	end
end

return Module

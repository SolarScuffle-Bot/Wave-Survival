--!strict

local CollectionService = game:GetService 'CollectionService'
local Players = game:GetService 'Players'
local player = Players.LocalPlayer

local Module = {}

Module.connections = {
	tool = {} :: {
		[Tool]: {
			equipped: RBXScriptConnection,
			unequipped: RBXScriptConnection,
			died: RBXScriptConnection?,
		},
	},

	tag = {} :: {
		[string]: {
			added: RBXScriptConnection,
			removed: RBXScriptConnection,
		},
	},
}

function Module.bindCharacter(characterAdded: (character: Model) -> (), characterRemoving: (character: Model) -> ())
	player.CharacterAdded:Connect(characterAdded)
	player.CharacterRemoving:Connect(characterRemoving)

	if player.Character then
		characterAdded(player.Character)
	end
end

export type ToolConnection = {
	equipped: RBXScriptConnection,
	unequipped: RBXScriptConnection,
	died: RBXScriptConnection?,
}

export type ToolConnections = {
	tool: {
		[Tool]: ToolConnection,
	},

	tag: {
		added: RBXScriptConnection,
		removed: RBXScriptConnection,
	},
}

export type ToolModule = {
	add: (tool: Tool) -> (),
	remove: (tool: Tool) -> (),
	equip: (tool: Tool, mouse: Mouse) -> (),
	unequip: (tool: Tool, mouse: Mouse) -> (),
}

function Module.bindTool(tagName: string, toolModule: ToolModule)
	local toolConnections = {} :: {
		[Tool]: {
			equipped: RBXScriptConnection,
			unequipped: RBXScriptConnection,
			died: RBXScriptConnection?,
		},
	}

	local function added(tool: Tool)
		toolModule.add(tool)

		local toolConnection = {} :: ToolConnection

		toolConnection.equipped = tool.Equipped:Connect(function(mouse: Mouse)
			local character = player.Character :: Model
			local humanoid = character:FindFirstChildWhichIsA 'Humanoid'
			if not humanoid then
				warn('No humanoid', character)
				return
			end

			if humanoid:GetState() == Enum.HumanoidStateType.Dead then
				return
			end

			if not toolConnection.died then
				toolConnection.died = humanoid.Died:Connect(function()
					toolModule.unequip(tool, mouse)
					toolConnection.died = nil
				end)
			end

			toolModule.equip(tool, mouse)
		end)

		toolConnection.unequipped = tool.Unequipped:Connect(function(mouse: Mouse)
			toolModule.unequip(tool, mouse)

			if toolConnection.died then
				toolConnection.died:Disconnect()
				toolConnection.died = nil
			end
		end)

		toolConnections[tool] = toolConnection

		if tool.Parent == player.Character then
			toolModule.equip(tool, player:GetMouse())
		end
	end

	local function removed(tool: Tool)
		toolModule.unequip(tool, player:GetMouse())
		toolModule.remove(tool)

		local connections = Module.connections[tool]
		if not connections then
			return
		end

		for _, connection in connections do
			connection:Disconnect()
		end

		Module.connections[tool] = nil
	end

	for _, tool in CollectionService:GetTagged(tagName) do
		if not tool:IsDescendantOf(Players) and not tool:IsDescendantOf(workspace) then
			warn('Tool not in Players or workspace', tool:GetFullName())
			continue
		end

		if tool:IsA 'Tool' then
			added(tool)
		end
	end

	return {
		name = tagName,
		tool = toolConnections,
		tag = {
			added = CollectionService:GetInstanceAddedSignal(tagName):Connect(added :: (Instance) -> ()),
			removed = CollectionService:GetInstanceRemovedSignal(tagName):Connect(removed :: (Instance) -> ()),
		},
	}
end

function Module.disconnectTool(connections: ToolConnections)
	for tool, toolConnection in connections.tool do
		toolConnection.equipped:Disconnect()
		toolConnection.unequipped:Disconnect()

		if toolConnection.died then
			toolConnection.died:Disconnect()
		end
	end

	for _, connection in pairs(connections.tag) do
		connection:Disconnect()
	end

	table.clear(connections)
end

return Module

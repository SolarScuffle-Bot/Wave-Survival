local ServerScriptService = game:GetService 'ServerScriptService'
local worlds = require(ServerScriptService.worlds)

local module = {}

worlds.Component.Build(script.Name, module)

return module
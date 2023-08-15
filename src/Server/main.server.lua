--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'
local ServerScriptService = game:GetService 'ServerScriptService'

local States = require(ReplicatedStorage.states)

do
	States.switch(States.states.intermission)

	task.delay(5, function()
		States.switch(States.states.waves)
	end)

	task.delay(7, function()
		States.switch(States.states.intermission)
	end)

	task.delay(9, function()
		States.switch(States.states.waves)
	end)
end

-- Not done yet, just gives players tools (THAT DON"T DO ANYTHING :SOB:)
do
	
end

local RunService = game:GetService 'RunService'
local Schedules = require(ServerScriptService.schedules)

do
	RunService.Heartbeat:Connect(Schedules.heartbeat.start)
end

do
	local TICK_FREQUENCY = 3 --? Surprisingly more than enough!
	local TICK_PERIOD = 1 / TICK_FREQUENCY

	local tickBuffer = 0
	RunService.Heartbeat:Connect(function(deltaTime: number)
		tickBuffer += deltaTime
		if tickBuffer >= TICK_PERIOD then
			Schedules.tick.start(tickBuffer)
			tickBuffer %= TICK_PERIOD
		end
	end)
end

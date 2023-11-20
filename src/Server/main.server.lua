--!strict

do
	local ReplicatedStorage = game:GetService 'ReplicatedStorage'
	local States = require(ReplicatedStorage.states)

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

do
	local ReplicatedStorage = game:GetService 'ReplicatedStorage'

	local Schedules = require(ReplicatedStorage.schedules)
	local RunService = game:GetService 'RunService'

	local TICK_FREQUENCY = 3 --? Surprisingly more than enough!
	local TICK_PERIOD = 1 / TICK_FREQUENCY

	local tickBuffer = 0
	RunService.Heartbeat:Connect(function(deltaTime: number)
		Schedules.heartbeat.start(deltaTime)

		tickBuffer += deltaTime
		if tickBuffer >= TICK_PERIOD then
			Schedules.tick.start(tickBuffer)
			tickBuffer %= TICK_PERIOD
		end
	end)
end

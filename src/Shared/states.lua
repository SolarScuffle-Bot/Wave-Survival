local function state()
	return {
		start = Instance.new 'BindableEvent',
		stop = Instance.new 'BindableEvent',
	}
end

export type State = typeof(state(...))

local Module = {}

Module.current = nil :: State?

Module.states = {
	waves = state(),
	intermission = state(),
}

function Module.switch(state: State?)
	if Module.current then
		Module.current.stop:Fire()
	end
	Module.current = state
	if state then
		state.start:Fire()
	end
end

function Module.connect(state: State, start: () -> (), stop: () -> ())
	state.start.Event:Connect(start)
	state.stop.Event:Connect(stop)
	if Module.current == state then
		state.start:Fire()
	end
end

return Module

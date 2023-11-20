local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Tools = ReplicatedStorage:WaitForChild 'Tools'
local Rounds = ReplicatedStorage:WaitForChild 'Rounds'

export type Round = BasePart
export type Cast = { type: 'hitscan', range: number } | { type: 'projectile', speed: number }
export type Inflection = 'pierce' | 'bounce'
export type Effect = 'explosion' | 'hole'

local Module = {}

Module.rounds = ''

Module.guns = {}

Module.guns[Tools.Sniper] = {
	capacity = 15,
	barrels = {
		primary = {
			cast = 'hitscan',
			range = 100,
			round = Rounds.Bullet,
			capacity = 1,
			hits = {
				{
					inflection = 'pierce',
					aoe = 0,
					effect = { 'hole' },
				},
			},
		},
	},
}

return Module

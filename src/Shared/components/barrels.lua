--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local Rounds = ReplicatedStorage:WaitForChild 'Rounds' :: Folder

local World = require(ReplicatedStorage.world)

local function isntNumber(value: unknown)
	return not value or typeof(value) ~= 'number' or value ~= value
end

local Module = {}

Module.get = {}

function Module.get.capacity(configuration: Configuration)
	local capacity = configuration:GetAttribute 'Capacity'
	if isntNumber(capacity) then
		local attachment = configuration.Parent :: Attachment
		error(
			`Invalid Capacity {tostring(capacity)} for barrel {attachment:GetFullName()}, should be a number; How will you know how many bullets go into this barrel?`
		)
	end
	return capacity
end

function Module.get.ammo(configuration: Configuration, capacity: number)
	local ammo = configuration:GetAttribute 'Ammo'
	if isntNumber(ammo) then
		local attachment = configuration.Parent :: Attachment
		error(
			`Invalid Ammo {tostring(ammo)} for barrel {attachment:GetFullName()}, should be a number; Remember, ammo wraps around if it is negative.`
		)
	end

	if ammo < 0 then
		ammo += 1 + capacity
	end

	return ammo
end

function Module.get.roundType(configuration: Configuration)
	if configuration:GetAttribute 'Bullet' then
		return 'hitscan'
	elseif configuration:GetAttribute 'Rocket' then
		return 'projectile'
	elseif configuration:GetAttribute 'Grenade' then
		return 'projectile'
	else
		local attachment = configuration.Parent :: Attachment
		error(
			`No RoundType found in barrel {attachment:GetFullName()}, should be a "Bullet" | "Rocket" | "Grenade" boolean attribute; The barrel needs to know what kind of round it is shooting!`
		)
	end
end

function Module.get.round(configuration: Configuration)
	if configuration:GetAttribute 'Bullet' then
		return Rounds:WaitForChild 'Bullet'
	elseif configuration:GetAttribute 'Rocket' then
		return Rounds:WaitForChild 'Rocket'
	elseif configuration:GetAttribute 'Grenade' then
		return Rounds:WaitForChild 'Grenade'
	else
		local attachment = configuration.Parent :: Attachment
		error(
			`No RoundType found in barrel {attachment:GetFullName()}, should be a "Bullet" | "Rocket" | "Grenade" boolean attribute; The barrel needs to know what kind of round it is shooting!`
		)
	end
end

function Module.get.range(configuration: Configuration)
	local range = configuration:GetAttribute 'Range'
	if isntNumber(range) then
		local attachment = configuration.Parent :: Attachment
		error(
			`Invalid Range {tostring(range)} for barrel {attachment:GetFullName()}; If you are making a hitscan weapon, you need to define a range.`
		)
	end
	return range
end

function Module.get.lifetime(configuration: Configuration)
	local lifetime = configuration:GetAttribute 'Lifetime'
	if isntNumber(lifetime) then
		local attachment = configuration.Parent :: Attachment
		error(
			`Invalid Lifetime {tostring(lifetime)} for barrel {attachment:GetFullName()}; Projectiles need a lifetime to know when to self-destruct, else they can potentially exist forever. If this is desired, set the lifetime to a negative number.`
		)
	end

	if lifetime < 0 then
		lifetime = math.huge
	end

	return lifetime
end

function Module.get.damage(hitConfiguration: Configuration)
	local damage = hitConfiguration:GetAttribute 'Damage' :: number
	if isntNumber(damage) then
		error(
			`Invalid hit configuration Damage {tostring(damage)} for {hitConfiguration:GetFullName()}, should be a number; Your bullets need to do some kind of damage when they hit something! Leave this as 0 if you don't want anything to be damaged.`
		)
	end
	return damage
end

function Module.get.damageType(hitConfiguration: Configuration)
	if hitConfiguration:GetAttribute 'Single' then
		return 'single'
	elseif hitConfiguration:GetAttribute 'Sphere' then
		return 'sphere'
	else
		error(
			`Invalid hit configuration DamageType for {hitConfiguration:GetFullName()}, should be a "Single" | "Sphere" boolean attribute.`
		)
	end
end

function Module.get.radius(hitConfiguration: Configuration)
	local radius = hitConfiguration:GetAttribute 'Radius' :: number?
	if isntNumber(radius) then
		error(
			`Invalid hit configuration Radius {tostring(radius)} for {hitConfiguration:GetFullName()}, should be a number; Since you chose a damage type of "Sphere" you need to specify how big that sphere is silly.`
		)
	end
	return radius
end

function Module.get.inflection(hitConfiguration: Configuration)
	if hitConfiguration:GetAttribute 'Pierce' then
		return 'pierce' :: string?
	elseif hitConfiguration:GetAttribute 'Bounce' then
		return 'bounce'
	else
		return nil
	end
end

function Module.get.impulse(hitConfiguration: Configuration)
	local impulse = hitConfiguration:GetAttribute 'Impulse' :: number?
	if isntNumber(impulse) or impulse and impulse < 0 then
		error(
			`Invalid hit configuration Impulse {tostring(impulse)} for {hitConfiguration:GetFullName()}, should be a positive number. Impulse here refers to the impulse applied on the round as it hits something.`
		)
	end
	return impulse
end

function Module.get.effects(hitConfiguration: Configuration)
	local effects = {}

	if hitConfiguration:GetAttribute 'Hole' then
		effects.hole = true
	end

	if hitConfiguration:GetAttribute 'Explosion' then
		effects.explosion = true
	end

	return effects
end

function Module.get.barrelData(configuration: Configuration)
	local barrel = {}

	barrel.capacity = Module.get.capacity(configuration)
	barrel.ammo = Module.get.ammo(configuration, barrel.capacity)
	barrel.round = Module.get.round(configuration)
	barrel.roundType = Module.get.roundType(configuration)

	if barrel.roundType == 'hitscan' then
		barrel.range = Module.get.range(configuration)
	elseif barrel.roundType == 'projectile' then
		barrel.lifetime = Module.get.lifetime(configuration)
	end

	barrel.hits = {}

	for _, hitConfiguration in configuration:GetChildren() do
		if not hitConfiguration:IsA 'Configuration' then
			error(
				`Invalid non-configuration {hitConfiguration.Name} under {configuration:GetFullName()}; These are meant to define what happens when a round hits something.`
			)
		end

		local order = tonumber(hitConfiguration.Name)
		if not order then
			error(
				`Invalid hit configuration Name {hitConfiguration.Name} under {configuration:GetFullName()}; This should be a number dictating the order this hit info is applied.`
			)
		end

		local hit = {}

		hit.damage = Module.get.damage(hitConfiguration)
		hit.damageType = Module.get.damageType(hitConfiguration)

		if hit.damageType == 'sphere' then
			hit.radius = Module.get.radius(hitConfiguration)
		end

		hit.inflection = Module.get.inflection(hitConfiguration)

		if hit.inflection == 'bounce' then
			hit.impulse = Module.get.impulse(hitConfiguration)
		end

		hit.effects = Module.get.effects(hitConfiguration)

		barrel.hits[order] = hit
	end

	return barrel
end

Module.factory = World.factory(script.Name, {
	add = function(factory, entity: Instance)
		local barrels = {}

		for _, attachment in entity:GetDescendants() do
			if not attachment:IsA 'Attachment' then
				continue
			end

			if not string.find(string.lower(attachment.Name), 'barrel') then
				continue
			end

			local configuration = attachment:FindFirstChildWhichIsA 'Configuration' :: Configuration
			if not configuration then
				continue
			end

			barrels[attachment.Name] = Module.get.barrelData(configuration)
		end

		if not next(barrels) then
			error(`{entity:GetFullName()} has no barrel attachments, but it was given the barrels component!`)
		end

		return barrels
	end,

	remove = function(factory, entity: Instance, component: Component) end,
})

export type Component = typeof(Module.factory.add(...))

return Module

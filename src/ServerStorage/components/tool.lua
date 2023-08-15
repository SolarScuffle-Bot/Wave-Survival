--!strict

local ReplicatedStorage = game:GetService 'ReplicatedStorage'

local World = require(ReplicatedStorage.world)

local Module = {}

Module.factory = World.factory(script.Name, Module)

return Module

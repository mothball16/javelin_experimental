--!strict
local Types = require(game:GetService("ReplicatedStorage"):WaitForChild("mMS_RS"):WaitForChild("Modules"):WaitForChild("Types"))

local module: Types.MissileConfig = {
	iterations = 10,
	peak = 0,
	initTime = 0.5,
	maxSpeed = 300,
	accel = 100,

	tandem = 0,
	radius = 16,
	ignoreWalls = false,
	initSpeed = 20,
	power = 500,
} 

return module

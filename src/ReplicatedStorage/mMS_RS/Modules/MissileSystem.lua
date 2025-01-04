--!strict


local MissileSys = {}
local HTTPS = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Packages = RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))


MissileSys.__index = MissileSys

type self = {
	missileType: string,
}



export type MissileSystem = typeof(setmetatable({} :: self, MissileSys))
-------------------------------------------------------------------



-------------------------------------------------------------------


local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")
local RunService = game:GetService("RunService")

local Events = mMS_RS:WaitForChild("Events")
local Models = mMS_RS:WaitForChild("Models")
local Modules = mMS_RS:WaitForChild("Modules")

-------------------------------------------------------------------

local function numLerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end


function MissileSys.new()	
	local self = setmetatable({} :: self, MissileSys)
	
	return self
end



return Missile

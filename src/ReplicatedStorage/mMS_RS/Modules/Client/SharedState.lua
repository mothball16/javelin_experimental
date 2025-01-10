--!strict
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))

export type State = {
    currentSystem: Types.MissileSystem?,
    systemIsSeat: boolean,
}

local state: State = {
    currentSystem = nil,
    systemIsSeat = false
}




return state
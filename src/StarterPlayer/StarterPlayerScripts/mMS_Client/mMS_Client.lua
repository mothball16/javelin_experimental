--!strict

--[[
load modules nyan !!!
]]

--services
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local _Packages = RS:WaitForChild("Packages")
local _Modules = mMS_RS:WaitForChild("Modules")
local Controllers = mMS_RS:WaitForChild("Controllers")



require(Controllers:WaitForChild("SysEquipController"))
require(Controllers:WaitForChild("MissileController"))
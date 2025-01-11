--!strict

--[[
load modules nyan !!!
]]

-- paths & services -------------------------------------------------------
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
--local Packages = RS:WaitForChild("Packages")
--local Modules = mMS_RS:WaitForChild("Modules")
local Controllers = mMS_RS:WaitForChild("Controllers")
-- dependencies -----------------------------------------------------------
-- constants --------------------------------------------------------------
-- vars -------------------------------------------------------------------
---------------------------------------------------------------------------


require(Controllers:WaitForChild("SysController")):Init()
require(Controllers:WaitForChild("MissileController")):Init()


print("mothballMissileSystem finished loading !!!!")

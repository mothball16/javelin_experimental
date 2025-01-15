--!strict

--[[
load modules nyan !!!
]]

-- paths & services -------------------------------------------------------
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
--local Packages = RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))
local Client = mMS_RS:WaitForChild("Client")
local EventBus = require(Client:WaitForChild("EventBus")) :: Types.EventBus
-- dependencies -----------------------------------------------------------
-- constants --------------------------------------------------------------
-- vars -------------------------------------------------------------------
---------------------------------------------------------------------------


require(Client:WaitForChild("SysHandler")):Init(EventBus)
require(Client:WaitForChild("MissileHandler")):Init(EventBus)


print("mothballMissileSystem finished loading !!!!")


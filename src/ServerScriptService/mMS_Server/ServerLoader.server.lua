--[[
load the stuff yeah
]]

-- paths & services -------------------------------------------------------
local SSS = game:GetService("ServerScriptService")
local mMS_Server = SSS:WaitForChild("mMS_Server")
local Service = mMS_Server:WaitForChild("Services")

---------------------------------------------------------------------------
for _,v in pairs(Service:GetChildren()) do
    require(v):Init()
end


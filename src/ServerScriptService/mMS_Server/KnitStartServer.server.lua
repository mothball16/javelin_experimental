local SSS = game:GetService("ServerScriptService")
local mMS_Server = SSS:WaitForChild("mMS_Server")
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = mMS_RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

Knit.AddServices(mMS_Server.Services)

Knit.Start({ServicePromises = false}):andThen(function()
	print("Knit started server")
end):catch(warn)



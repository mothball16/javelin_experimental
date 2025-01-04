local SSS = game:GetService("ServerScriptService")
local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

Knit.AddServices(SSS.Services)

Knit.Start({ServicePromises = false}):andThen(function()
	print("Knit started server")
end):catch(warn)



local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = mMS_RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

Knit.AddControllersDeep(mMS_RS:WaitForChild("Controllers"))


Knit.Start({ServicePromises = false}):andThen(function()
	print("Knit started client")
end):catch(warn)


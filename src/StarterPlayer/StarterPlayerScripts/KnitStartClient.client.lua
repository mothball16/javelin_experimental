local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))

Knit.AddControllersDeep(RS:WaitForChild("Controllers"))


Knit.Start({ServicePromises = false}):andThen(function()
	print("Knit started client")
end):catch(warn)


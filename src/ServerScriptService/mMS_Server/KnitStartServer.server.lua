--!strict
local SSS = game:GetService("ServerScriptService")
local mMS_Server = SSS:WaitForChild("mMS_Server")
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = mMS_RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
Knit.AddServices(mMS_Server.Services)

Knit.Start({ServicePromises = false}):andThen(function()
	print("Knit started server")
	local AttachableService = Knit.GetService("AttachableService")
	
	local _,attachment = AttachableService:Create("JavelinLTA")
	attachment.Parent = game.Workspace
	attachment:PivotTo(CFrame.new(0,20,0))
end):catch(warn)



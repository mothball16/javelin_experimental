local tool = script.Parent.Parent
local char,hum,idleAnim
local anims = tool:WaitForChild("Animations")

local RS = game:GetService("RunService")

tool.Equipped:Connect(function()
	char = tool.Parent
	hum = char:WaitForChild("Humanoid")
	idleAnim = hum:LoadAnimation(anims:FindFirstChild("Hold"))
	idleAnim:Play()
end)

tool.Unequipped:Connect(function()
	idleAnim:Stop()
end)

tool.Activated:Connect(function()
	tool.Handle:Destroy()
	tool.Missile.Parent = game.Workspace
	idleAnim:Stop()
	game.Debris:AddItem(tool,0)
end)


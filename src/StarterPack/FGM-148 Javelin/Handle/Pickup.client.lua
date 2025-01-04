local tool = script.Parent.Parent
local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local anims = tool:WaitForChild("Animations")
local idleAnim

tool.Equipped:Connect(function()
	local uiClone = script.Parent.JavUI:Clone()
	uiClone.JavControl.Enabled = true
	uiClone.Parent = player.PlayerGui
	if idleAnim == nil then
		idleAnim = hum:LoadAnimation(anims:FindFirstChild("Hold"))

	end
	idleAnim:Play()
end)

tool.Unequipped:Connect(function()
	if player.PlayerGui:FindFirstChild("JavUI") then
		player.PlayerGui:FindFirstChild("JavUI"):Destroy()
	end
	player.CameraMaxZoomDistance = game.StarterPlayer.CameraMaxZoomDistance
	
	for i,v in pairs(tool:GetDescendants()) do
		if v:IsA("BasePart") and v:FindFirstChild("OrigTrans") then

			v.Transparency = v:FindFirstChild("OrigTrans").Value
			v:FindFirstChild("OrigTrans"):Destroy()
		end
	end
	
	idleAnim:Stop()
	
	--backup stuff
	game.Workspace.CurrentCamera.FieldOfView = 70
	hum.WalkSpeed = 16
end)
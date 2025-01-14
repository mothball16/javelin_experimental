--!strict
--[[
Those grey border thingys on the javelin



prop drilling depth 2 (STOP!!!!)
]]

local RS = game:GetService("ReplicatedStorage")
local RUS = game:GetService("RunService")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = RS:WaitForChild("Packages")
local Modules = mMS_RS:WaitForChild("Modules")
local Types = require(Modules:WaitForChild("Types"))
local React = require(Packages:WaitForChild("ReactLua"))
local Charm = require(Packages:WaitForChild("Charm"))
local UseMotion = require(Modules:WaitForChild("UseMotion"))
local UseAtom = require(Packages:WaitForChild("ReactCharm")).useAtom
local e = React.createElement


local function Crosshair(props: Types.CrosshairProps)
	local trans, transMotor = UseMotion(0)
	local pct = UseAtom(props.pct)
	local pos = UseAtom(props.pos)

	React.useEffect(function(): () 
		if pct <= 0 or pct >= 1 then
			transMotor:spring(1 - pct)
		else
			transMotor:spring( 1 - math.abs(math.sin(tick() * 6)))
		end
	end, {pct})
			

	return e(
		"Frame",{
			AnchorPoint = Vector2.new(0.500, 0.500),
			BackgroundTransparency = 1,
			Position = pos,
			Size = UDim2.fromScale(1,1),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Visible = true,
			ZIndex = -11,
		},{
			Horiz = e("Frame",{
					BorderSizePixel = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5,0.5),
					Size = UDim2.new(1, 0, 0, 2),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderColor3 = Color3.new(0,0,0),
					BackgroundTransparency = trans,
					ZIndex = -5,
				}),

			Vert = e("Frame",{
					BorderSizePixel = 1,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5,0.5),
					Size = UDim2.new(0, 2, 1, 0),
					BackgroundColor3 = Color3.new(1,1,1),
					BorderColor3 = Color3.new(0,0,0),
					BackgroundTransparency = trans,
					ZIndex = -5,
				})
		}
	)	
end



return Crosshair



--[[
ARCHIVED

		old code form when it was seeking bool atom
		if pct >= 1 then
			transMotor:spring(0)
		elseif pct > 0 then
			local connection = RUS.RenderStepped:Connect(function(dt: number)
				cycle += dt
				transMotor:spring( 1 - math.abs(math.sin(cycle * 6)))
			end)
			
			return function()
				connection:Disconnect()
				transMotor:spring(1)
			end
		else
			transMotor:spring(1)
		end]]
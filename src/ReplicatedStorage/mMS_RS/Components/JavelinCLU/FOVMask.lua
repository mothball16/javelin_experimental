--!strict
--[[
Those grey border thingys on the javelin



prop drilling depth 2 (STOP!!!!)
]]

local RS = game:GetService("ReplicatedStorage")
local RUS = game:GetService("RunService")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Packages = RS:WaitForChild("Packages")

local Types = require(Modules:WaitForChild("Types"))
local React = require(Packages:WaitForChild("ReactLua"))
local Charm = require(Packages:WaitForChild("Charm"))
local UseAtom = require(Packages:WaitForChild("ReactCharm")).useAtom
local e = React.createElement

local ZOOM_TYPES = {
	["wide"] = {
		ratio = 1.5,
		width = 0.375,
	},
	["narrow"] = {
		ratio = 1,
		width = 0.375/1.5,
	}
}

local function FOVMask(props: Types.FOVMaskProps)
	local zoomType = UseAtom(props.zoomType)
	local visible = UseAtom(props.visible)
	local seeking = UseAtom(props.seeking)
	local visFinal = visible and seeking
	local frame = React.useRef(nil :: Frame?)
	
	React.useEffect(function() : ()
		if frame.current then
			local connection = (frame.current):GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
				props.bounds({
					pos = frame.current.AbsolutePosition + Vector2.new(0,game:GetService("GuiService"):GetGuiInset().Y),
					size = frame.current.AbsoluteSize
				})
			end)
			return function()
				connection:Disconnect()
			end
		end
	end)

	React.useEffect(function() : ()
		if frame.current then
			local connection = (frame.current):GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
				props.bounds({
					pos = frame.current.AbsolutePosition + Vector2.new(0,game:GetService("GuiService"):GetGuiInset().Y),
					size = frame.current.AbsoluteSize
				})
			end)
			return function()
				connection:Disconnect()
			end
		end
	end)



	print("hullo!!")
	return e(
		"Frame",{
			ref = frame,
			AnchorPoint = Vector2.new(0.500, 0.500),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.500, 0, 0.500, 0),
			Size = UDim2.new(ZOOM_TYPES[zoomType].width, 0, 1.000, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Visible = visFinal,
			ZIndex = -1000,
		},{
			Ratio = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = ZOOM_TYPES[zoomType].ratio
			}),
			FrameRight = e(
				"Frame",{
					BorderSizePixel = 0,
					Position = UDim2.new(1.000, 0, -5.000, 0),
					Size = UDim2.new(10.000, 0, 10.000, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150),
					ZIndex = -1000,
				}),
			FrameLeft = e(
				"Frame",{
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(1.000, 0.000),
					Position = UDim2.new(0.000, 0, -5.000, 0),
					Size = UDim2.new(10.000, 0, 10.000, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150),
					ZIndex = -1000,
				}),
			FrameBottom = e(
				"Frame",{
					BorderSizePixel = 0,
					Position = UDim2.new(0.000, 0, 1.000, 0),
					Size = UDim2.new(1.000, 0, 10.000, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150),
					ZIndex = -1000,
				}),
			FrameTop = e(
				"Frame",{
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0.000, 1.000),
					Size = UDim2.new(1.000, 0, 10.000, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150),
					ZIndex = -1000,
				})
		}
	)	
end



return FOVMask

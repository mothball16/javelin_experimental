--!strict
--[[
Those grey border thingys on the javelin



prop drilling depth 2 (STOP!!!!)
]]

local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local React = require(Packages:WaitForChild("ReactLua"))
local Charm = require(Packages:WaitForChild("Charm"))
local UseAtom = require(Packages:WaitForChild("ReactCharm")).useAtom

local ZOOM_TYPES = {
	["wide"] = {
		ratio = 1.5,
		width = 0.3,
	},
	["narrow"] = {
		ratio = 1,
		width = 0.2,
	}
}

local function FOVMask(props: {
	visible: Charm.Atom<boolean>,
	zoomType: Charm.Atom<string>,
	seeking: Charm.Atom<boolean>,
})
	local zoomType = UseAtom(props.zoomType)
	local visible = UseAtom(props.visible)
	local seeking = UseAtom(props.seeking)
	local visFinal = visible and seeking
	return React.createElement(
		"Frame",{
			AnchorPoint = Vector2.new(0.500, 0.500),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.500, 0, 0.500, 0),
			Size = UDim2.new(ZOOM_TYPES[zoomType].width, 0, 1.000, 0),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			Visible = visFinal,
			ZIndex = -1,
		},{
			Ratio = React.createElement("UIAspectRatioConstraint", {
				AspectRatio = ZOOM_TYPES[zoomType].ratio
			}),
			FrameRight = React.createElement(
				"Frame",{
					BorderSizePixel = 0,
					Position = UDim2.new(1.000, 0, -5.000, 0),
					Size = UDim2.new(10.000, 0, 10.000, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				}),
			FrameLeft = React.createElement(
				"Frame",{
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(1.000, 0.000),
					Position = UDim2.new(0.000, 0, -5.000, 0),
					Size = UDim2.new(10.000, 0, 10.000, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				}),
			FrameBottom = React.createElement(
				"Frame",{
					BorderSizePixel = 0,
					Position = UDim2.new(0.000, 0, 1.000, 0),
					Size = UDim2.new(1.000, 0, 10.000, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				}),
			FrameTop = React.createElement(
				"Frame",{
					BorderSizePixel = 0,
					AnchorPoint = Vector2.new(0.000, 1.000),
					Size = UDim2.new(1.000, 0, 10.000, 0),
					BackgroundColor3 = Color3.fromRGB(150, 150, 150)
				})
		}
	)	
end



return FOVMask

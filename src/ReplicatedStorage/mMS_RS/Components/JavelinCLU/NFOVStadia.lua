--!strict
-- generated from roblox to roact plugin

-- paths & services -------------------------------------------------
local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
-- dependencies -------------------------------------------------------
local React = require(Packages:WaitForChild("ReactLua"))
local Charm = require(Packages:WaitForChild("Charm"))
local UseAtom = require(Packages:WaitForChild("ReactCharm")).useAtom
local e = React.createElement
---------------------------------------------------------------------


local function NFOVStadia(props: {
    zoomType: Charm.Atom<string>
})
	UseAtom(props.zoomType)

	return e("Frame", {
	Size = UDim2.new(1.000, 0, 1.000, 0),
	ZIndex = -10000,
	BackgroundTransparency = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	Visible = (props.zoomType() == "narrow")
	}, {
	Top = e("Frame", {
	AnchorPoint = Vector2.new(0.500, 0.000),
	Position = UDim2.new(0.500, 0, 0.000, -1),
	Size = UDim2.new(0.000, 3, 0.375, 0),
	ZIndex = -100000,
	BorderSizePixel = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	}),
	
	Bottom = e("Frame", {
	AnchorPoint = Vector2.new(0.500, 1.000),
	Position = UDim2.new(0.500, 0, 1.000, 1),
	Size = UDim2.new(0.000, 3, 0.375, 0),
	ZIndex = -100000,
	BorderSizePixel = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	}),
	
	Left = e("Frame", {
	AnchorPoint = Vector2.new(0.000, 0.500),
	Position = UDim2.new(0.000, -1, 0.500, 0),
	Size = UDim2.new(0.375, 0, 0.000, 3),
	ZIndex = -100000,
	BorderSizePixel = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	}),
	
	Right = e("Frame", {
	AnchorPoint = Vector2.new(1.000, 0.500),
	Position = UDim2.new(1.000, 1, 0.500, 0),
	Size = UDim2.new(0.375, 0, 0.000, 3),
	ZIndex = -100000,
	BorderSizePixel = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	}),
	
	StadiaRight = e("Frame", {
	Position = UDim2.new(0.522, 0, 0.000, 0),
	Size = UDim2.new(0.000, 3, 0.250, 0),
	ZIndex = -100000,
	BorderSizePixel = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	}),
	
	StadiaLeft = e("Frame", {
	AnchorPoint = Vector2.new(1.000, 0.000),
	Position = UDim2.new(0.477, 0, 0.000, 0),
	Size = UDim2.new(0.000, 3, 0.250, 0),
	ZIndex = -100000,
	BorderSizePixel = 1,
	BackgroundColor3 = Color3.fromRGB(255, 255, 255),
	})})
end

return NFOVStadia




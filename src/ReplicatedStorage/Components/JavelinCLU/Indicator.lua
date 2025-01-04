--[[
Non-interactible indicator component for the CLU stuff.
No state needs to be maintained, this is just to make the thing light up.
]]


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)
local indicator = Roact.Component:extend("Indicator")

function indicator:init(props)
	
end

function indicator:render()
	return Roact.createElement("ImageLabel", {
		Position = UDim2.fromScale(0,0),
		Size = UDim2.fromScale(1,1),
		ZIndex = 2,
		BackgroundTransparency = 1,
		
	})
end



return indicator
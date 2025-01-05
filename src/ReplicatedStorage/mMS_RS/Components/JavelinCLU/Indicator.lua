--[[
Non-interactible indicator component for the CLU stuff.
No state needs to be maintained, this is just to make the thing light up.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local React = require(ReplicatedStorage.Packages.ReactLua.React)

local function Indicator(props)
	props.on = props.on or 0
	props.off = props.off or 0.9
	props.visible = props.visible or false

	React.useEffect(function()
		
	end,{props.visible})

	return React.createElement("ImageLabel",{
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ImageTransparency = 0.9,
		Image = props.image
	})
end


return Indicator
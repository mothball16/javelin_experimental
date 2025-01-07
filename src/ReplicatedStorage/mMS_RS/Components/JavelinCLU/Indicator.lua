--[[
Non-interactible indicator component for the CLU stuff.
No state needs to be maintained, this is just to make the thing light up.
]]

local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local React = require(mMS_RS.Packages.ReactLua)
local UseMotion = require(mMS_RS.Modules.UseMotion)


local function Indicator(props)
	props.on = props.on or 0
	props.off = props.off or 0.9
	props.visible = props.visible or false

	local scale, scaleMotor = UseMotion(0)
	
	
	React.useEffect(function()
		scaleMotor:spring(props.visible and props.on or props.off, {
			damping = 0.3,
		})

		print(scale)
	end,{props.visible})

	return React.createElement("ImageLabel",{
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ImageTransparency = scale,
		Image = props.image
	})
end



return Indicator

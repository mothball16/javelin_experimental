--!strict
--[[
Non-interactible indicator component for the CLU stuff


prop drilling depth 2 (STOP!!!!!)
]]

local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local React = require(RS:WaitForChild("Packages"):WaitForChild("ReactLua"))
local UseMotion = require(mMS_RS:WaitForChild("Modules"):WaitForChild("UseMotion"))


local function Indicator(props: {
	on: number?,
	off: number?,
	visible: boolean?,
	onSound: string?,
	offSound: string?,
	image: string,
})
	props.on = props.on or 0 :: number
	props.off = props.off or 0.9 :: number
	props.visible = props.visible or false
	props.offSound = props.offSound or "yuh"
	props.onSound = props.onSound or "yuh"
	assert(props.on and props.off and props.onSound and props.offSound,"wtf you arent upposed to reach this")

	local scale, scaleMotor = UseMotion(0)
	
	
	React.useEffect(function()
		scaleMotor:spring(props.visible and props.on or props.off, {
			damping = 0.7,
			friction = 0.2,
			mass = 0.05,
		})

	end,{props.visible})

	return React.createElement("ImageLabel",{
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ImageTransparency = scale,
		Image = props.image
	})
end



return Indicator

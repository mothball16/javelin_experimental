--!strict
--[[
Non-interactible indicator component for the CLU stuff


prop drilling depth 2 (STOP!!!!!)
]]
local SOS = game:GetService("SoundService")
local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local React = require(RS:WaitForChild("Packages"):WaitForChild("ReactLua"))
local UseMotion = require(mMS_RS:WaitForChild("Modules"):WaitForChild("UseMotion"))
local e = React.createElement


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
	assert(props.on and props.off,"wtf you arent upposed to reach this")
	local loaded = React.useRef(false)
	local scale, scaleMotor = UseMotion(0)
	
	
	React.useEffect(function()
		if loaded.current and props.visible and props.onSound then
			local s = Instance.new("Sound",game.Players.LocalPlayer.PlayerGui)
			s.SoundId = props.onSound
			s.PlaybackSpeed = 0.9 + math.random()/20
			s:Play()

			game.Debris:AddItem(s,s.TimeLength)
		else
			loaded.current = true
		end

		scaleMotor:spring(props.visible and props.on or props.off, {
			damping = 0.7,
			friction = 0.2,
			mass = 0.05,
		})
	end,{props.visible})

	return e("ImageLabel",{
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1,1),
		ImageTransparency = scale,
		Image = props.image
	})
end



return Indicator

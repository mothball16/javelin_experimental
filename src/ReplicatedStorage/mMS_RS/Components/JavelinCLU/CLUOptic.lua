--!strict
local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local React = require(Packages.ReactLua.React)
local CLUFolder = script.Parent
local CLUIndicator = require(CLUFolder:WaitForChild("Indicator"))
local Signal = require(Packages.Signal)


--defined params to fix type checking bug (Maybe this is a good practice too Ion know)
local function CLUOptic(props: {
	indicators: {[string]: {image: string, state: boolean}},
	updateSignal: Signal.Signal<any>
})
	local children = {

	}

	local state, setState = React.useState(table.clone(props.indicators))


	for k,v in pairs(props.indicators) do
		print(k,v)
		table.insert(children,React.createElement(CLUIndicator,{
			Name = k,
			image = v.image,
			visible = true,
			on = 0,
			off = 0.9,
		}))
	end
	
	React.useEffect(function()
		local connection = props.updateSignal:Connect(function(newState)
			print("reached!")
			
			local updateState = table.clone(state)
			for k, v in pairs(newState) do
				if updateState[k] then
					updateState[k][state] = v.state
				end
			end
			setState(updateState)
		end)

		return function()
			connection:Disconnect()
		end
	end)

	return React.createElement("ImageLabel",{
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Name = "HUD",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.9,0,1.2,0),
		Image = "rbxassetid://107048180741183",
		ScaleType = Enum.ScaleType.Stretch
	}, children)
end


return CLUOptic


--!strict
local CLUFolder = script.Parent
local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")

local React = require(Packages.ReactLua)
local Signal = require(Packages.Signal)
local CLUIndicator = require(CLUFolder:WaitForChild("Indicator"))

local BORDER_COLOR = Color3.fromRGB(0,0,0)


--defined params to fix type checking bug (Maybe this is a good practice too Ion know)
local function CLUOptic(props: {
	indicators: {[string]: {image: string, state: boolean}},
	updateSignal: Signal.Signal<any>,
	zoomSignal: Signal.Signal<boolean>,
})
	local children = {
		Ratio = React.createElement("UIAspectRatioConstraint",{}),
		Borders = React.createElement("Frame",{
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1)
			
		},{
			Left = React.createElement("Frame",{
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1,0),
				Position = UDim2.fromScale(0,0),
				Size = UDim2.fromScale(1,1),
				BackgroundColor3 = BORDER_COLOR
			}),
			Right = React.createElement("Frame",{
				BorderSizePixel = 0,
				Position = UDim2.fromScale(1,0),
				Size = UDim2.fromScale(1,1),
				BackgroundColor3 = BORDER_COLOR
			}),
			Bottom = React.createElement("Frame",{
				BorderSizePixel = 0,
				Position = UDim2.fromScale(-5,1),
				Size = UDim2.fromScale(10,1),
				BackgroundColor3 = BORDER_COLOR
			}),
			Top = React.createElement("Frame",{
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(0,1),
				Position = UDim2.fromScale(-5,0),
				Size = UDim2.fromScale(10,1),
				BackgroundColor3 = BORDER_COLOR
			}),
		}),
	}

	local state, setState = React.useState(table.clone(props.indicators))
	local vis, setVis = React.useState(false)

	for k,v in pairs(props.indicators) do
		children[k] = React.createElement(CLUIndicator,{
			Name = k,
			image = v.image,
			visible = state[k].state,
			on = 0,
			off = 0.9,
		})
	end
	
	React.useEffect(function()
		local connection = props.updateSignal:Connect(function(newState)
			local updateState = table.clone(state)
			for k, v in pairs(newState) do
				if updateState[k] then
					updateState[k].state = v
				end
			end
			setState(updateState)
		end)

		return function()
			connection:Disconnect()
		end
	end)

	React.useEffect(function()
		local connection = props.zoomSignal:Connect(function(newState)
			setVis(newState)
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
		ScaleType = Enum.ScaleType.Stretch,
		Visible = vis,
	}, {children})
end


return CLUOptic


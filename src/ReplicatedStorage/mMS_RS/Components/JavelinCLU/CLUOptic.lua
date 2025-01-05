--!strict
local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local React = require(Packages.ReactLua.React)
local CLUFolder = script.Parent
local CLUIndicator = require(CLUFolder:WaitForChild("Indicator"))
local Signal = require(Packages.Signal)
local BORDER_COLOR = Color3.fromRGB(0,0,0)

local function tableMerge(t1, t2): {any}
	local nt = table.clone(t1)
	for _, v in pairs(t2) do
		table.insert(nt,v)
	end
	return nt
end
--defined params to fix type checking bug (Maybe this is a good practice too Ion know)
local function CLUOptic(props: {
	indicators: {[string]: {image: string, state: boolean}},
	updateSignal: Signal.Signal<any>
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


	for k,v in pairs(props.indicators) do
		children[k] = React.createElement(CLUIndicator,{
			Name = k,
			image = v.image,
			visible = true,
			on = 0,
			off = 0.9,
		})
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
	}, {children})
end


return CLUOptic


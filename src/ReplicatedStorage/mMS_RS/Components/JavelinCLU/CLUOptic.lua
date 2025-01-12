--!strict


-- prop drilling depth 1


-- paths & services -------------------------------------------------------
local RS = 				game:GetService("ReplicatedStorage")
local Packages = 		RS:WaitForChild("Packages")
local CLUFolder = 		script.Parent

-- dependencies -----------------------------------------------------------
local Charm = 			require(Packages:WaitForChild("Charm"))
local React = 			require(Packages:WaitForChild("ReactLua"))
local Signal = 			require(Packages:WaitForChild("Signal"))
local CLUIndicator = 	require(CLUFolder:WaitForChild("Indicator"))
local FOVMask =         require(CLUFolder:WaitForChild("FOVMask"))
local UseAtom = 		require(Packages:WaitForChild("ReactCharm")).useAtom

-- constants --------------------------------------------------------------
local BORDER_COLOR =	Color3.fromRGB(0,0,0)

-- vars -------------------------------------------------------------------

---------------------------------------------------------------------------

--defined params to fix type checking bug (Maybe this is a good practice too Ion know)
local function CLUOptic(props: {
	indicators: {[string]: {image: string, state: boolean}},
	updateSignal: Signal.Signal<any>,
	visible: Charm.Atom<boolean>,
	zoomType: Charm.Atom<string>,
	seeking: Charm.Atom<boolean>,
})
	local state, setState = React.useState(table.clone(props.indicators))
	local vis = UseAtom(props.visible)

	local children = {
		Mask = React.createElement(FOVMask,{
			visible = props.visible,
			zoomType = props.zoomType,
			seeking = props.seeking,
		}),


		Ratio = React.createElement("UIAspectRatioConstraint",{}),

		SightBorders = React.createElement("ImageLabel",{
			AnchorPoint = Vector2.new(0.5,0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Name = "HUD",
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Image = "rbxassetid://107048180741183",
			ScaleType = Enum.ScaleType.Stretch,
		}),


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
					updateState[k].state = v.state
				end
			end
			setState(updateState)
		end)

		return function()
			connection:Disconnect()
		end
	end)


	return React.createElement("Frame",{
		AnchorPoint = Vector2.new(0.5,0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Name = "Main",
		BackgroundTransparency = 1,
		Size = UDim2.new(0.9,0,1.2,0),
		Visible = vis,
	}, {children})
end


return CLUOptic


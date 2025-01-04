local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.Roact)

-- Individual ToggleButton component
local ToggleButton = Roact.Component:extend("ToggleButton")

function ToggleButton:init()
	self:setState({
		isActive = false
	})
end

function ToggleButton:render()
	return Roact.createElement("TextButton", {
		Text = self.state.isActive and "ON" or "OFF",
		Size = UDim2.new(0, 100, 0, 50),
		Position = self.props.position,
		BackgroundColor3 = self.state.isActive 
			and Color3.fromRGB(0, 255, 0) 
			or  Color3.fromRGB(255, 0, 0),
		[Roact.Event.MouseButton1Click] = function()
			self:setState({
				isActive = not self.state.isActive
			})
			-- Call the provided action function if it exists
			if self.props.onToggle then
				self.props.onToggle(not self.state.isActive)
			end
		end
	})
end

-- Main UI component that uses multiple toggle buttons
local ToggleUI = Roact.Component:extend("ToggleUI")

function ToggleUI:init()
	-- Example functions that will be called when buttons are toggled
	self.actions = {
		button1Action = function(isActive)
			print("Button 1 is now:", isActive)
			-- Add your custom action here
		end,
		button2Action = function(isActive)
			print("Button 2 is now:", isActive)
			-- Add your custom action here
		end
	}
end

function ToggleUI:render()
	return Roact.createElement("Frame", {
		Size = UDim2.new(0, 300, 0, 400),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = Color3.fromRGB(200, 200, 200),
	}, {
		-- Title
		Title = Roact.createElement("TextLabel", {
			Text = "Toggle Controls",
			Size = UDim2.new(1, 0, 0, 50),
			BackgroundTransparency = 1,
			TextSize = 24,
		}),

		-- First toggle button
		Button1 = Roact.createElement(ToggleButton, {
			position = UDim2.new(0.5, -50, 0.3, 0),
			onToggle = self.actions.button1Action
		}),

		-- Second toggle button
		Button2 = Roact.createElement(ToggleButton, {
			position = UDim2.new(0.5, -50, 0.5, 0),
			onToggle = self.actions.button2Action
		})
	})
end

-- Mount the UI to PlayerGui when ready
local function mountUI(player)
	local handle = Roact.mount(
		Roact.createElement(ToggleUI),
		player.PlayerGui,
		"ToggleUI"
	)

	-- Store handle somewhere if you need to unmount later
	-- To unmount: Roact.unmount(handle)
end
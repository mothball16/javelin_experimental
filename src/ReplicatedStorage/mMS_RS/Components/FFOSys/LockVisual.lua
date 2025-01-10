local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local React = require(RS:WaitForChild("Packages"):WaitForChild("ReactLua"))
local UseMotion = require(mMS_RS:WaitForChild("Modules"):WaitForChild("UseMotion"))

local e = React.createElement
local function LockVisual(props)
    local lockPercent, setLockPercent = React.useState(0)
    local scale, scaleMotor = UseMotion(0)
    local function createCornerEdge(anchor: Vector2, pos: UDim2)
        return e(
            React.Fragment,
            nil,
            e("Frame", {
                Position = pos,
                AnchorPoint = anchor,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Size = scale:map(function(v) return UDim2.new(0,1,v/2,0) end),
            }),
            e("Frame", {
                Position = pos,
                AnchorPoint = anchor,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Size = scale:map(function(v) return UDim2.new(v/2,0,0,1) end),
            })
        ) 
    end
    
    
    local children = {
        Ratio = React.createElement("UIAspectRatioConstraint",{
            AspectRatio = 1
        }),
        TL = createCornerEdge(Vector2.new(0,0), UDim2.fromScale(0,0)),
        TR = createCornerEdge(Vector2.new(1,0), UDim2.fromScale(1,0)), 
        BR = createCornerEdge(Vector2.new(1,1), UDim2.fromScale(1,1)),
        BL = createCornerEdge(Vector2.new(0,1), UDim2.fromScale(0,1)),
    }
       
    React.useEffect(function()
        local connection = props.updateSignal:Connect(setLockPercent)

        scaleMotor:spring(lockPercent, {
			damping = 0.7,
            mass = 0.1,
		})
        return function()
            connection:Disconnect()
        end
    end)
    
    return e("Frame",{
        Name = "LockFrame",
        BackgroundTransparency = 1,
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.08, 1),
        AnchorPoint = Vector2.new(0.5,0.5),
        Visible = lockPercent ~= 1,
    }, children)
end


return LockVisual
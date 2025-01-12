--!strict
--[[
component for making the frame thingy and yeah



prop drilling depth 1
]]

-- paths & services -------------------------------------------------------
local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
-- dependencies -----------------------------------------------------------
local React = require(Packages:WaitForChild("ReactLua"))
local Charm = require(Packages:WaitForChild("Charm"))
local Types = require(Modules:WaitForChild("Types"))
local UseAtom = require(Packages:WaitForChild("ReactCharm")).useAtom
local UseMotion = require(Modules:WaitForChild("UseMotion"))

-- vars -------------------------------------------------------------------
local e = React.createElement
---------------------------------------------------------------------------


local function LockVisual(props:{
    pct: Charm.Atom<number>,
    pos: Charm.Atom<UDim2>
})
    local pct = UseAtom(props.pct)
    local pos = UseAtom(props.pos)

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
                Size = scale:map(function(v: number) return UDim2.new(0,1,v/2,0) end),
            }),    
            e("Frame", {
                Position = pos,
                AnchorPoint = anchor,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Size = scale:map(function(v: number) return UDim2.new(v/2,0,0,1) end),
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
       
    scaleMotor:spring(pct, {
        damping = 0.7,
        mass = 0.1,
    }) 
    
    
    return e("Frame",{
        Name = "LockFrame",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(pos.X.Offset,pos.Y.Offset),
        Size = UDim2.fromScale(0.08, 1),
        AnchorPoint = Vector2.new(0.5,0.5),
        Visible = true,
    }, children)
end


return LockVisual
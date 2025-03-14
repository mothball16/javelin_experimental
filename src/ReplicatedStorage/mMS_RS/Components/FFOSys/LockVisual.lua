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
-- constants --------------------------------------------------------------
local LINE_THICKNESS = 4

local function LockVisual(props: {
    pct: Charm.Atom<number>,
    pos: Charm.Atom<UDim2>,
    from: UDim2?,
    to: UDim2?,
})

    props.from = props.from or UDim2.fromScale(0.08,1)
    props.to = props.to or UDim2.fromScale(0.01, 1)
    assert(props.from and props.to, "props.from or props.to doesn't exisst")
    local pct = UseAtom(props.pct)
    local pos = UseAtom(props.pos)
    local trans, transMotor = UseMotion(0)
    local scale, scaleMotor = UseMotion(0)

    local function createCornerEdge(anchor: Vector2, pos: UDim2)
        return e(
            React.Fragment,
            nil,
            --vert
            e("Frame", {
                Position = pos,
                AnchorPoint = anchor,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 1,
                Size = scale:map(function(v: number) return UDim2.new(0,LINE_THICKNESS,0.1 + v/8,0) end),
                ZIndex = 2
            }),    

            --horiz
            e("Frame", {
                Position = pos,
                AnchorPoint = anchor,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 1,
                Size = scale:map(function(v: number) return UDim2.new(0.1 + v/8,0,0,LINE_THICKNESS) end),
            }),

            --fix clipping (scuffed fix)
            e("Frame",{
                Position = pos,
                AnchorPoint = anchor,
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Size = scale:map(function(v: number) return UDim2.new(0.1 + v/8,0,0,LINE_THICKNESS) end),
                ZIndex = 3
            })
        ) 
    end
    
    local children = {
        Ratio = e("UIAspectRatioConstraint",{
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
        Size = props.from:Lerp(props.to, pct),
        AnchorPoint = Vector2.new(0.5,0.5),
        Visible = props.pct() > 0,
    }, children)
end


return LockVisual
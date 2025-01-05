--!strict

--[[
composition for any locking mechanism. has mechanics for establishing, breaking a lock, and updating the interface as such
]]

local RS = game:GetService("ReplicatedStorage")
local mMS_RS = RS:WaitForChild("mMS_RS")
local Packages = RS:WaitForChild("Packages")
local Components = mMS_RS:WaitForChild("Components")
local Signal = require(Packages:WaitForChild("Signal"))
local React = require(Packages:WaitForChild("ReactLua"))
local ReactRoblox = require(Packages:WaitForChild("ReactRoblox"))
local LockVisual = require(Components:WaitForChild("FFOSys"):WaitForChild("LockVisual"))

--------------------------------------------------------------------------
local PGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")


--------------------------------------------------------------------------
--local Types = require(Modules:WaitForChild("Types"))

local TargetLocker = {}
TargetLocker.__index = TargetLocker

type self = {
    root: any,
    interface: ScreenGui,
    lockAtt: Attachment?,
	lockPercent: number,

    updateConnection: RBXScriptConnection?,
	OnLockStarted: Signal.Signal<Attachment>,
	OnLockEnded: Signal.Signal<>,
	UpdateLock: Signal.Signal<number>,
}

export type TargetLocker = typeof(setmetatable({} :: self, TargetLocker))

function TargetLocker.new()
    local self = setmetatable({} :: self, TargetLocker)

    self.updateConnection = nil
	self.lockAtt = nil
    self.UpdateLock = Signal.new()

    --set up the React interface
    self.root = ReactRoblox.createRoot(Instance.new("Folder",PGui))
    self.root:render(ReactRoblox.createPortal(React.createElement(
        "ScreenGui",{
            IgnoreGuiInset = true
        },{ 
            React.createElement(LockVisual,
            {
                updateSignal = self.UpdateLock
            })
    }),PGui))
    return self
end

function TargetLocker.BeginLock(self: TargetLocker, origin: Vector3, target: Vector3, rayParams: RaycastParams): boolean
    local rayResult = game.Workspace:Raycast(origin,target,rayParams)
    if rayResult and rayResult.Instance then
        local att = Instance.new("Attachment",rayResult.Instance)
        att.WorldPosition = rayResult.Position
        self.lockAtt = att
        return true
    end
    self.OnLockStarted:Fire(self.lockAtt :: Attachment)
    return false
end

function TargetLocker.EndLock(self: TargetLocker)
    if self.lockAtt then 
        self.lockAtt:Destroy() 
        self.lockAtt = nil
    end
    self.lockPercent = 0
    self.OnLockEnded:Fire()
end

function TargetLocker.Cleanup(self: TargetLocker)
    self:EndLock()
    self.root:unmount()
    self.interface:Destroy()
end

    
return TargetLocker
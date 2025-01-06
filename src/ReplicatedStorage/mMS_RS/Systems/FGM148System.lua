--!strict

--[[

]]

local RS = game:GetService("ReplicatedStorage")
local Packages = RS:WaitForChild("Packages")
local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")
local Modules = mMS_RS:WaitForChild("Modules")
local Systems = mMS_RS:WaitForChild("Systems")
local Components = mMS_RS:WaitForChild("Components")

local React = require(Packages.ReactLua)
local ReactRoblox = require(Packages.ReactRoblox)
local TargetLocker = require(Systems:WaitForChild("TargetLocker"))
local HandheldBase = require(Systems:WaitForChild("HandheldBase"))
local Signal = require(Packages:WaitForChild("Signal"))
local CLUOptic = require(Components:WaitForChild("JavelinCLU"):WaitForChild("CLUOptic"))
local e = React.createElement
local WeaponComponent = require(Modules.WeaponComponent)
----------------------------------------------------------------
local C_PATH = mMS_RS.Models.JavelinParts
local INDICATOR_DEFAULTS =  {
    ["BCU+"] =      {image = "rbxassetid://89722159180463", state = false},
    ["CLU"] =       {image = "http://www.roblox.com/asset/?id=99363953262967", state = false},
    ["CLU+"] =      {image = "rbxassetid://120742308197590", state = false},
    ["DAY"] =       {image = "rbxassetid://78672229303453", state = true},
    ["DIR"] =       {image = "rbxassetid://130596689947010", state = false},
    ["FAIL"] =      {image = "rbxassetid://87552336360294", state = false},
    ["FLTR"] =      {image = "rbxassetid://100690720477052", state = false},
    ["HANGFIRE"] =  {image = "rbxassetid://80690717062067", state = false},
    ["MSL"] =       {image = "rbxassetid://113910383142154", state = false},
    ["NFOV"] =      {image = "rbxassetid://116625289291108", state = false},
    ["NIGHT"] =     {image = "http://www.roblox.com/asset/?id=108927303018110", state = false},
    ["SEEK"] =      {image = "rbxassetid://122333432415827", state = false},
    ["TOP"] =       {image = "rbxassetid://81416663556280", state = true},
    ["WFOV"] =      {image = "rbxassetid://97724947789086", state = true},
}

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local PGui = plr.PlayerGui
local cam = game.Workspace.CurrentCamera

----------------------------------------------------------------



local FGM148System = {}
FGM148System.__index = FGM148System

type self = {
    locker: TargetLocker.TargetLocker,
    rayParams: RaycastParams,
    indicators: {[string]: {image: string, state: boolean}},
    root: any,
    clu: ScreenGui,
    UpdateState: Signal.Signal<any>,
    state: Folder,
    
}

export type FGM148System = typeof(setmetatable({} :: self, FGM148System)) & HandheldBase.HandheldBase



--- initialize object and set up self. 
function FGM148System.new(args: {
    object: Model,
}): FGM148System
    local self = setmetatable(HandheldBase.new({
        object = args.object,
        state = args.object:FindFirstChild("mMS_State") :: Folder
    }) :: FGM148System, FGM148System)
    local handle: BasePart = args.object:FindFirstChild("Handle") :: BasePart
    
    self.locker = TargetLocker.new()
    self.UpdateState = Signal.new()
    self.indicators = table.clone(INDICATOR_DEFAULTS)

    -- set up ray params: should ignore self and launcher
    self.rayParams = RaycastParams.new()
    self.rayParams.FilterDescendantsInstances = {char, self.object}
    self.rayParams.FilterType = Enum.RaycastFilterType.Exclude

    self.components = {
        ["CLU"] = WeaponComponent.new({
            model = C_PATH:FindFirstChild("CLU"),
            attach = handle,
            attached = true,
        }),
        ["Housing"] = WeaponComponent.new({
            model = C_PATH:FindFirstChild("Housing"),
            attach = handle,
            attached = true,
            children = {
                {
                    model = "Warhead",
                    attached = false
                }
            }
        })
    }
    print(self.components["Housing"]:GetTree())

    return self
end



--- set up connections to create functionality
function FGM148System.Setup(self: FGM148System)
    -- set up the CLU
    self.root = ReactRoblox.createRoot(Instance.new("Folder"))
    self.root:render(ReactRoblox.createPortal(e(
        "ScreenGui",{
            IgnoreGuiInset = true
        },{
            e(CLUOptic,
            {
                indicators = self.indicators,
                updateSignal = self.UpdateState 
            })
        }),PGui))
    




    
    coroutine.resume(coroutine.create(function()
        while true do
            task.wait(0.5)
            local key = next(INDICATOR_DEFAULTS)
            self.locker.UpdateLock:Fire(math.random())
            self.UpdateState:Fire({[key] = (math.random() > 0.5 and true or false)})
        end
    end))
end

function FGM148System.Cleanup(self: FGM148System)
    self.root:unmount()
  
    --self.clu:Destroy()
end


return FGM148System
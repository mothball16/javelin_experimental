--!strict


-- paths & services -----------------------------------------------------------------------
local RS =              game:GetService("ReplicatedStorage")
local RUS =             game:GetService("RunService")
local mMS_RS =          RS:WaitForChild("mMS_RS")
local Packages =        RS:WaitForChild("Packages")
local Modules =         mMS_RS:WaitForChild("Modules")
local Components =      mMS_RS:WaitForChild("Components")
local Client =          mMS_RS:WaitForChild("Client")
local CLUFolder =       Components:WaitForChild("JavelinCLU")
-- dependencies ---------------------------------------------------------------------------
local React =           require(Packages.ReactLua)
local ReactRoblox =     require(Packages.ReactRoblox)

local EventBus =        require(Client:WaitForChild("EventBus"))
local Signal =          require(Packages:WaitForChild("Signal"))
local Input =           require(Packages:WaitForChild("Input"))
--local Net =             require(Packages:WaitForChild("Net"))
local Charm =           require(Packages:WaitForChild("Charm"))
local Maid =            require(Modules:WaitForChild("Maid"))
local Types =           require(Modules:WaitForChild("Types"))
local TargetLocker =    require(Modules:WaitForChild("TargetLocker"))
local HandheldBase =    require(Modules:WaitForChild("HandheldBase"))
local GlobalConfig =    require(Modules:WaitForChild("GC"))

local MissileConfig =   require(mMS_RS:WaitForChild("Configs"):WaitForChild("Missiles"):WaitForChild("FGM-148 Warhead"))

local CLUOptic =        require(CLUFolder:WaitForChild("CLUOptic"))
local Crosshair = 		require(CLUFolder:WaitForChild("Crosshair"))
local FOVMask =         require(CLUFolder:WaitForChild("FOVMask"))
local NFOVStadia =      require(CLUFolder:WaitForChild("NFOVStadia"))
local WFOVStadia =      require(CLUFolder:WaitForChild("WFOVStadia"))
-- constants ------------------------------------------------------------------------------
local MSL_TYPE = "FGM-148 Warhead"
local SWITCH_ON = "rbxassetid://9120102763"
local INDICATOR_DEFAULTS =  {
    ["BCU_PLUS"] = {
        image = "rbxassetid://89722159180463", 
        state = false
    },
    ["CLU"] = {
        image = "http://www.roblox.com/asset/?id=99363953262967", 
        state = false
    },
    ["CLU_PLUS"] = {
        image = "rbxassetid://120742308197590", 
        state = false
    },
    ["DAY"] = {
        image = "rbxassetid://78672229303453",
        onSound = SWITCH_ON,
        state = true
    },
    ["DIR"] = {
        image = "rbxassetid://130596689947010", 
        onSound = SWITCH_ON,
        state = false
    },
    ["FAIL"] = {
        image = "rbxassetid://87552336360294", 
        state = false
    },
    ["FLTR"] = {
        image = "rbxassetid://100690720477052", 
        onSound = SWITCH_ON,
        state = false
    },
    ["HANGFIRE"] = {
        image = "rbxassetid://80690717062067", 
        state = false
    },
    ["MSL"] = {
        image = "rbxassetid://113910383142154", 
        state = false
    },
    ["NFOV"] = {
        image = "rbxassetid://116625289291108", 
        onSound = SWITCH_ON,
        state = false
    },
    ["NIGHT"] = {
        image = "http://www.roblox.com/asset/?id=108927303018110", 
        onSound = SWITCH_ON,
        state = false
    },
    ["SEEK"] = {
        image = "rbxassetid://122333432415827", 
        state = false
    },
    ["TOP"] = {
        image = "rbxassetid://81416663556280",
        onSound = SWITCH_ON,
        state = true
    },
    ["WFOV"] =      {
        image = "rbxassetid://97724947789086", 
        onSound = SWITCH_ON,
        state = true
    },

}

local BINDS: {[string]: Enum.KeyCode} = {
    ["Seek"] = Enum.KeyCode.F,
    ["Path"] = Enum.KeyCode.G,
    ["NV"] = Enum.KeyCode.H,
    ["FOV"] = Enum.KeyCode.T,
}

--(wide is 4x, narrow is 9x)
local WIDE_FOV = 70/4
local NARROW_FOV = 70/9

-- vars ------------------------------------------------------------------------------------
local e = React.createElement

local Keyboard, Mouse = Input.Keyboard.new(), Input.Mouse.new()

local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local PGui = plr.PlayerGui
local cam = game.Workspace.CurrentCamera

-------------------------------------------------------------------------------------------


local FGM148System = {}
FGM148System.__index = FGM148System

type self = {
    Targeter: TargetLocker.TargetLocker,
    rayParams: RaycastParams,
    indicators: {[string]: {image: string, state: boolean, [string]: any}},
    root: any,
    OnIndicatorsUpdated: Signal.Signal<{[string]: {image: string, state: boolean}}>,
    OnZoomToggled: Signal.Signal<boolean>,
    
    nv: Charm.Atom<boolean>,
    seeking: Charm.Atom<boolean>,
    zoomed: Charm.Atom<boolean>,
    zoomType: Charm.Atom<string>,
    missilePath: Charm.Atom<string>,
    bounds: Charm.Atom<{pos: Vector2, size: Vector2}>,

    firePart: BasePart,
}

export type FGM148System = typeof(setmetatable({} :: self, FGM148System)) & HandheldBase.HandheldBase


--- initialize object and set up self
function FGM148System.new(args: {
    object: Model,
}): FGM148System
    local self = setmetatable(HandheldBase.new({
        object = args.object,
    }) :: FGM148System, FGM148System)
    self._maid = Maid.new()

    self.firePart = self.object:FindFirstChild("FirePart") :: BasePart

    -- create rayparams
    self.rayParams = RaycastParams.new()
    self.rayParams.FilterDescendantsInstances = {args.object, char}
    self.rayParams.FilterType = Enum.RaycastFilterType.Exclude

    --setup signals
    self.OnIndicatorsUpdated = Signal.new()
    self.OnZoomToggled = Signal.new()
    self.indicators = table.clone(INDICATOR_DEFAULTS)

    --guaranteed state vars on loadup
    self.zoomed = Charm.atom(false)
    self.seeking = Charm.atom(false)
    self.zoomType = Charm.atom("wide")
    self.bounds = Charm.atom({pos = Vector2.new(), size = Vector2.new()})

    --not guaranteed state vars (but they R here for now.
    self.missilePath = Charm.atom("TOP")
    self.nv = Charm.atom(false)
        

    --set up the locking system
    self.Targeter = TargetLocker.new({
        rayParams = self.rayParams,
        checkWall = true,
        maxDist = 2000,
        lockTime = 0.5,
        bounds = self.bounds,
    })


    self._maid:GiveTask(self.Targeter)
    self._maid:GiveTask(self.OnIndicatorsUpdated)
    self._maid:GiveTask(self.OnZoomToggled)



    return self
end


function FGM148System.InitInterface(self: FGM148System)
-- set up the CLU
    self.root = ReactRoblox.createRoot(Instance.new("Folder"))
    self.root:render(ReactRoblox.createPortal(e(
     "ScreenGui",{
        IgnoreGuiInset = true
     },{
         e(CLUOptic,
         {
             indicators = self.indicators,
             updateSignal = self.OnIndicatorsUpdated,
             visible = self.zoomed, 

             nfovStadia = e(NFOVStadia, {
                zoomType = self.zoomType,
             }),
            
             wfovStadia = e(WFOVStadia, {
                zoomType = self.zoomType,
             }),

             Mask = e(FOVMask,{
                zoomType = self.zoomType,
                visible = self.zoomed,
                seeking = self.seeking,
                bounds = self.bounds,
             })
             
         }),

         Crosshair = e(Crosshair,{
            pos = self.Targeter.lockPos,
            pct = self.Targeter.lockPct,
         }),
     }),PGui))

        --handle indicator updates
    self._maid:GiveTask(Charm.effect(function()
        self.indicators.SEEK.state = self.Targeter.lockPct() >= 1
        self.indicators.TOP.state = self.missilePath() == "TOP"
        self.indicators.DIR.state = self.missilePath() == "DIR"
        self.indicators.NIGHT.state = self.nv()
        self.indicators.DAY.state = not self.nv()
        self.indicators.WFOV.state = self.zoomType() == "wide"
        self.indicators.NFOV.state = self.zoomType() == "narrow"
        self.OnIndicatorsUpdated:Fire(self.indicators)       
    end))

    --eventually cleanup the root when the javelin is unequipped
    self._maid:GiveTask(function()
        self.root:unmount()
    end)

end

--- set up connections to create functionality
function FGM148System.Setup(self: FGM148System)
    self:InitInterface()

    --connect fire/zoom (mouse button stuff)
    self._maid:GiveTask(Mouse.LeftDown:Connect(function()
        self:Fire()
    end))
    self._maid:GiveTask(Mouse.RightDown:Connect(function()
        self.zoomed(not self.zoomed())
    end))

    --connect inputs
    self._maid:GiveTask(Keyboard.KeyDown:Connect(function(key: Enum.KeyCode)
        if key == BINDS.Seek then
            if self.Targeter:CreateLock(char.Head.Position, cam.CFrame.LookVector.Unit * 1000) then
                self.seeking(true)
            end
        elseif key == BINDS.FOV then
            self.zoomType(self.zoomType() == "wide" and "narrow" or "wide")
        elseif key == BINDS.Path then
            self.missilePath(self.missilePath() == "TOP" and "DIR" or "TOP")
        elseif key == BINDS.NV then
            self.nv(not self.nv())
        end
    end))

    self._maid:GiveTask(Keyboard.KeyUp:Connect(function(key: Enum.KeyCode)
        if key == BINDS.Seek then
            self.seeking(false)
            self.Targeter:DestroyLock()
        end
    end))

    --automatically change FOV when zoomed/zoomType is changed
    self._maid:GiveTask(Charm.effect(function()
        if self.zoomed() then
            if self.zoomType() == "wide" then
                cam.FieldOfView = WIDE_FOV
            else
                cam.FieldOfView = NARROW_FOV
            end
        else
            cam.FieldOfView = GlobalConfig.defaultFOV
        end
    end))

    --handle seeking updates
    self._maid:GiveTask(Charm.effect(function()
        if self.seeking() then
            self._maid.seekConnection = RUS.RenderStepped:Connect(function(dt: number)
                local lockAtt = self.Targeter.lockAtt()
                if lockAtt then

                    if self.Targeter:Check(char.Head.Position, (lockAtt.WorldPosition - char.Head.Position).Unit * self.Targeter.config.maxDist :: number) then
                        self.Targeter:Update(dt)
                    else
                        self.seeking(false)
                        self.Targeter:DestroyLock()
                        self._maid.seekConnection = nil 
                    end
                else
                    self._maid.seekConnection = nil
                end
            end)
        else
            self._maid.seekConnection = nil
        end
    end))
end

function FGM148System.Destroy(self: FGM148System)
    self.zoomed(false)
    self._maid:DoCleaning()
    --self.clu:Destroy()
end


function FGM148System.Fire(self: FGM148System)
    local lockAtt = self.Targeter.lockAtt()
    if lockAtt and self.Targeter.lockPct() >= 1 then
        local passAtt = lockAtt:Clone()
        passAtt.Parent = lockAtt.Parent

        local fields = MissileConfig({
            attackDir = self.missilePath() :: "TOP" | "DIR",
            dist = (self.firePart.Position - lockAtt.WorldPosition).Magnitude
        }) :: Types.MissileFields
        fields.origin = self.firePart.Position
        fields.initOrient = self.firePart.CFrame
        fields.target = lockAtt.WorldPosition
        fields.att = passAtt
        fields.model = MSL_TYPE

        EventBus.Missile.SendCreationRequest:Fire(fields)
    end
end



return FGM148System
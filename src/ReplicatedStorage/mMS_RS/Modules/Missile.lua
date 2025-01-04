--!strict


local Missile = {}
local HTTPS = game:GetService("HttpService")
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local Packages = RS:WaitForChild("Packages")
local Knit = require(Packages:WaitForChild("Knit"))
local Types = require(script.Parent.Types)

Missile.__index = Missile


--i gave up having every type in the Types file for not having to maintain a separate methods type
type self = {
	target: Vector3,		-- the position of the target/to be sent updates by the launcher
	att: Attachment?,
	
	lastTick: number, 		-- the last tick where the missile orientation was updated
	lastPos: Vector3, 		-- the position of the missile on the last frame - for hit detection
	lastTarget: Vector3, 	-- the position of the target on the last update - for prediction
	progress: number,		-- number from 0 to 1 (for the height equation)

	lifetime: number,		-- 0
	active: boolean,		-- false
	object: Model,			-- the name of the model
	main: BasePart,			-- main part of the missile
	speed: number,			-- the magnitude of the missile speed
	
	initVel: LinearVelocity,
	mainVel: LinearVelocity,
	mainRot: AlignOrientation,
	connections: {[string]: RBXScriptConnection},
	fields: Types.MissileFields
}




export type Missile = typeof(setmetatable({} :: self, Missile))
-------------------------------------------------------------------
local PEAK_CALC_THETA = 60
local PHASE_BREAKPOINT = 0.25
local PREDICTION_CONFIDENCE = 0.02
local BUFFER_MIN = 0.05
local BUFFER_MAX = 0.25
local FORWARD_TRACK = 50
-------------------------------------------------------------------


local mMS_RS = game.ReplicatedStorage:WaitForChild("mMS_RS")
local RunService = game:GetService("RunService")

local Events = mMS_RS:WaitForChild("Events")
local Models = mMS_RS:WaitForChild("Models")
local Modules = mMS_RS:WaitForChild("Modules")
local Missiles = mMS_RS:WaitForChild("Missiles")
local ConfigDefaults = require(Missiles:WaitForChild("Configs"):WaitForChild("Defaults"))
-------------------------------------------------------------------

local function numLerp(a: number, b: number, t: number): number
	return a + (b - a) * t
end


function Missile.new(fields: Types.MissileFields)	
	local self = setmetatable({} :: self, Missile)
	--set fields
	self.fields = fields
	self.fields.identifier = HTTPS:GenerateGUID()
	setmetatable(self.fields,{__index = ConfigDefaults})
	
	
	--positions
	self.target = self.fields.target
	self.att = self.fields.att
	
	--tracking
	self.lastTick = tick()
	self.lastPos = self.fields.origin
	
	--state
	self.progress = 0
	self.lifetime = 0
	self.active = false
	self.object = Models:FindFirstChild(fields.model):Clone()
	
	--get peak altitude
	self.fields.peak = math.min(self.fields.peak :: number, math.tan(math.rad(PEAK_CALC_THETA)) * (self:GetDist() * PHASE_BREAKPOINT))
	self.connections = {}
	
	--set vars
	self.speed = self.fields.initSpeed :: number
	self.lastTarget = self.fields.target
	
	--get essential parts
	self.main = self.object:WaitForChild("Main") :: BasePart
	self.initVel = self.main:FindFirstChild("InitVel") :: LinearVelocity
	self.mainVel = self.main:FindFirstChild("MainVel") :: LinearVelocity
	self.mainRot = self.main:FindFirstChild("MainRot") :: AlignOrientation
	assert(self.initVel and self.mainRot and self.mainVel, "something is missing: InitVel, MainVel, MainRot")
	
	
	--sloppy function override
	if self.fields.functions then
		for k, v in pairs(self.fields.functions) do
			self[k] = v
		end
	end
	
	----------------------------------------------------------------------------

	--set up the object in the workspace
	self.object.Parent = game.Workspace
	self.object:PivotTo(self.fields.initOrient)
	return self
end

function Missile.Snapshot(self: Missile): Types.MissileSnapshot
	return {
		ver = os.clock(),
		cf = self.main.CFrame,
		active = self.active
	}
end

--add missile functionality (isn't called for replicated missiles)
function Missile.Init(self: Missile)
	assert(self.fields.initSpeed :: number)
	--set up the movers
	self.main.Anchored = false

	--double-check the thingy thingy
	self.mainVel.Enabled = false
	self.initVel.Enabled = true
	self.mainRot.Enabled = true

	--set movers
	self.initVel.VectorVelocity = self.fields.initOrient.LookVector.Unit * self.fields.initSpeed
	self.mainRot.CFrame = self.main.CFrame
	--wait till ignition, set up the coroutine
	coroutine.resume(coroutine.create(function()
		assert(self.fields.maxSpeed and self.fields.accel)
		task.wait(self.fields.initTime)
		
		
		self.connections["accel"] = RunService.Heartbeat:Connect(function(dt)
			self.speed = self.speed + (self.fields.accel * dt)
			self:UpdateForces()
			--break once max speed is reached (no more changes to speed)
			if self.speed >= self.fields.maxSpeed then
				self.speed = self.fields.maxSpeed
				self:UpdateForces()
				self.connections["accel"]:Disconnect()
			end
		end)
		
		
		local RayParams = RaycastParams.new()
		RayParams.FilterDescendantsInstances = {self.object}
		RayParams.FilterType = Enum.RaycastFilterType.Exclude
		
		self.connections["cast"] = RunService.Heartbeat:Connect(function()
			local direction = (self.main.Position - self.lastPos).Unit
			local mag = (self.main.Position - self.lastPos).Magnitude


			local result = game.Workspace:Raycast(self.lastPos,direction*mag,RayParams)
			if result and result.Instance.Transparency < 1 then
				self.connections["cast"]:Disconnect()
				self.active = false
				self:Explode()
			end
		end)
		
		self.mainVel.VectorVelocity = self.initVel.VectorVelocity
		self.initVel.Enabled = false
		self.mainVel.Enabled = true
		self.active = true
		self:LaunchFX()
	end))
	
end


--get distance ignoring altitude
function Missile.GetDist(self: Missile,origin: Vector3?, target: Vector3?): number
	origin = origin or self.fields.origin
	target = target or self.target
	assert(target and origin, "target or origin is nil")
	return ((origin - target) * Vector3.new(1,0,1)).Magnitude
end

--get distance from 0 to 1 based off missile distance to target, as compared to from the origin to target
function Missile.GetDistNormalized(self:Missile): number
	return 1 - math.clamp(self:GetDist(self.main.Position,nil)/self:GetDist(),0,1)
end


--predict the position of the target at point of impact
function Missile.PredictIntercept(self: Missile): (Vector3, number)
	assert(self.fields.iterations,self.fields.maxSpeed,self.fields.accel)
	
	--cache vars
	local origin: Vector3 		= self.main.Position
	local elapsed: number 		= tick() - self.lastTick
	local displacement: Vector3 = self.target - self.lastTarget
	local velocity: Vector3 	= displacement / elapsed
	local calibSpeed: number 	= math.min(self.fields.maxSpeed, self.speed + self.fields.accel) --the speed when you first fire overcompensates way too hard so add acceleration of 1 second
	
	--TTT estimate 1: assume straight path to the target
	local timeToTarget: number 	= (origin - self.target).Magnitude / calibSpeed
	local interceptPos: Vector3 = self.target + (velocity * timeToTarget)
	for i = 0, self.fields.iterations, 1 do
		local newTTT: number 	= (origin - interceptPos).Magnitude / calibSpeed
		local newInt: Vector3	= self.target + (velocity * newTTT)
		
		--check convergence: break early if results are close enough
		if math.abs(newTTT - timeToTarget) < PREDICTION_CONFIDENCE then
			return newInt, newTTT
		end
		
		timeToTarget = newTTT
		interceptPos = newInt
	end
	return interceptPos, timeToTarget
end


--https://www.desmos.com/calculator/l2kb4axhr4
function Missile.GetDesiredAltitude(self: Missile, progress: number): number
	assert(self.fields.peak :: number, "self.fields.peak isn't a number?")

	progress = math.clamp(progress,0,1)
	if progress < PHASE_BREAKPOINT then
		return (math.sin(2 * math.pi * progress)^0.5 * self.fields.peak) + self.fields.origin.Y
	else
		return (math.sin((2 * math.pi) / 3 * (progress + 0.5)) * self.fields.peak) + self.target.Y
	end
end


--update the movers to point and move in the given direction (I suck at Physics !!)
function Missile.UpdateForces(self: Missile, dir: CFrame?)

	assert(self.fields.power,"power is null?")
	if dir then
		self.mainVel.VectorVelocity = dir.LookVector.Unit * self.speed
	    self.mainRot.CFrame = dir
	else
		self.mainVel.VectorVelocity = self.mainVel.VectorVelocity.Unit * self.speed
	end
	--self.mainRot.CFrame = CFrame.lookAt(self.lastPos,self.lastPos)
	self.mainVel.MaxForce = self.fields.power
end



----------------------------methods (customizable)---------------------------------------------




function Missile.LaunchFX(self: Missile)
	local burnSFX = self.main:FindFirstChild("BurnSFX") :: Sound
	local fireVFX = self.object:FindFirstChild("ThrustEmitter"):FindFirstChild("Fire") :: ParticleEmitter
	local smokeVFX = self.object:FindFirstChild("ThrustEmitter"):FindFirstChild("Smoke") :: ParticleEmitter 
	burnSFX:Play()
	fireVFX.Enabled = true
	smokeVFX.Enabled = true
end

--one iteration of missile logic
function Missile.Run(self: Missile)
	if not self.active then return end
	--grab flight data n stuff
	local progress = self:GetDistNormalized()
	if self.att then
		self.target = self.att.WorldPosition
	end

	--figure out the new target to point to
	local newTarget, timeToTarget = self:PredictIntercept()
	local directionToTarget = (newTarget - self.main.Position).Unit
	local finalTarget = Vector3.new(self.main.Position.X + directionToTarget.X * FORWARD_TRACK, self:GetDesiredAltitude(progress),self.main.Position.Z + directionToTarget.Z * FORWARD_TRACK)
	newTarget = finalTarget
	
	--orient the missile
	self:UpdateForces(CFrame.lookAt(self.main.Position, newTarget))
	

	--update the data
	self.lastPos = self.main.Position
	self.lastTick = tick()
	self.lastTarget = self.target
end

function Missile.Explode(self:Missile)
	self.main.Anchored = true
	for i,v in pairs(self.object:GetDescendants()) do
		if v:IsA("BasePart") then
			v.Transparency = 1
		end
	end
end


function Missile.Abort(self: Missile)
	self.active = false

	for i,v in pairs(self.object:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = true
		end
	end
	task.wait(5)
	--self:Destroy()
end


function Missile.Interp(self: Missile, from: Types.MissileSnapshot, to: Types.MissileSnapshot, delta: number)
	TS:Create(self.main,TweenInfo.new(delta,Enum.EasingStyle.Linear),{CFrame = to.cf}):Play()
	if from.active ~= to.active and to.active == true then
		self:LaunchFX()
	end
end
--[[
function Missile:Destroy()
	if self.Connection then self.Connection:Disconnect() end
	self.Obj:Destroy()
	self.Targ:Destroy()
end

function Missile:Explode()
	if self.Connection then self.Connection:Disconnect() end
	self.Obj.Main.Anchored = true
	for i,v in pairs(self.Obj:GetDescendants()) do
		pcall(function()
			v.Transparency = 1
		end)
	end
	self.Obj.ExplosionEmitter.Fire.Enabled = true
	self.Obj.ExplosionEmitter.Smoke.Enabled = true
	self.Obj.Main.ExplodeSFX:Play()
	self.Obj.ThrustEmitter:Destroy()
	self.Obj.Main.BurnSFX:Stop()
	coroutine.resume(coroutine.create(function()
		wait(0.5)
		self.Obj.ExplosionEmitter.Fire.Enabled = false
		self.Obj.ExplosionEmitter.Smoke.Enabled = false
		wait(5)
		self:Destroy()
	end))
	
	local explosion = Instance.new("Explosion")
	explosion.Position = self.Obj.Main.Position
	explosion.BlastRadius = self.ExplRadius
	explosion.BlastPressure = 50000
	explosion.DestroyJointRadiusPercent = 0
	explosion.Parent = game.Workspace
	explosion.Hit:Connect(function(hit)
		local mag = (hit.Position - self.Obj.Main.Position).Magnitude
		if hit.Name == "Head" and hit.Parent:FindFirstChild("Humanoid") then
			local damageFactor = 1 - mag/self.ExplRadius
			hit.Parent:FindFirstChild("Humanoid"):TakeDamage(self.PDamage * damageFactor)
		end
	end)
end]]

return Missile

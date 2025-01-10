local config = {

  --If you for any reason already have an attribute named mothballMissileSystem then rename this to something other than mothballMissileSystem
  Identification = "mothballMissileSystem",

  MissileMaxLifeTime = 30,
  MissileReplicationDelay = 0.1, --Changing this may reduce network load but also will make missiles appear choppier/delayed on other clients

  




  ---binds-------------------------------------------------------------------------------------------
  -- dropped -> tool
  pickupBind = Enum.KeyCode.H,
  -- tool -> dropped, embedded -> tool, embedded -> dropped
  detachBind = Enum.KeyCode.G,

 
  stateName = "mMS_State",

    
}



return config


--[=[
ARCHIVED


 ---troubleshooting/compatibility-------------------------------------------------------------------
  --[[
  If the Knit framework is already somewhere in your game, set loadKnit to false and do the following:
  Move services to wherever the currently existing Knit gets services, and do the same for controllers
        ^ (located in mMS_Server.Services)                            (located in mMS_RS.Controllers) ^
  - Delete the currently existing Knit (mMS_RS.Packages.Knit.lua)
  - Change every mention of "local Knit = require(Packages:WaitForChild("Knit"))" 
    to wherever your Knit is located
  - (Originally there was a KnitPath var here but it broke intellisense so you have to do it manually)

  ]]
  loadKnit = true, 


]=]
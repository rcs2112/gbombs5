AddCSLuaFile()
-- Sounds
sound.Add( {
	name = "Motor_Small",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {140, 140},
	sound = "gbombs_5/launch/rocket.wav"
} )
sound.Add( {
	name = "Motor_Small2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {120, 120},
	sound = "gbombs_5/launch/rocket.wav"
} )


sound.Add( {
	name = "Motor_Medium",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	pitch = {100, 100},
	sound = "gbombs_5/launch/rocket.wav"
} )

sound.Add( {
	name = "Motor_Medium2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 130,
	pitch = {80, 80},
	sound = "gbombs_5/launch/rocket.wav"
} )

sound.Add( {
	name = "Motor_Large2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 160,
	pitch = {50, 50},
	sound = "gbombs_5/launch/rocket.wav"
} )
-- End
DEFINE_BASECLASS( "base_anim" )

local ImpactSounds = {}
ImpactSounds[1]                      =  "chappi/imp0.wav"
ImpactSounds[2]                      =  "chappi/imp1.wav"
ImpactSounds[3]                      =  "chappi/imp2.wav"
ImpactSounds[4]                      =  "chappi/imp3.wav"
ImpactSounds[5]                      =  "chappi/imp4.wav"
ImpactSounds[6]                      =  "chappi/imp5.wav"
ImpactSounds[7]                      =  "chappi/imp6.wav"
ImpactSounds[8]                      =  "chappi/imp7.wav"
ImpactSounds[9]                      =  "chappi/imp8.wav"
ImpactSounds[10]                     =  "chappi/imp9.wav"

local damagesound                    =  "weapons/rpg/shotdown.wav"

local ExploSnds = {}
ExploSnds[1]                         =  "BaseExplosionEffect.Sound"

ENT.Spawnable		            	 =  false     
ENT.AdminSpawnable		             =  false       

ENT.PrintName		                 =  "Rogue"            
ENT.Author			                 =  "Rogue"       
ENT.Contact			                 =  "crap" 
ENT.Category                         =  "Explosives"   

ENT.Model                            =  ""            
ENT.RocketTrail                      =  ""            
ENT.RocketBurnoutTrail               =  ""            
ENT.Effect                           =  ""            
ENT.EffectAir                        =  ""            
ENT.EffectWater                      =  ""           
ENT.ExplosionSound                   =  ""            
ENT.StartSound                       =  ""            
ENT.ArmSound                         =  ""            
ENT.ActivationSound                  =  ""      
ENT.EngineSound                      =  "Missile.Ignite"  
ENT.NBCEntity                        =  "" 

ENT.ShouldUnweld                     =  false          
ENT.ShouldIgnite                     =  false         
ENT.UseRandomSounds                  =  false     
ENT.SmartLaunch                      =  true     
ENT.Timed                            =  false 
ENT.IsNBC                            =  false

ENT.ExplosionDamage                  =  0            
ENT.ExplosionRadius                  =  0             
ENT.PhysForce                        =  0             
ENT.SpecialRadius                    =  0             
ENT.MaxIgnitionTime                  =  5             
ENT.Life                             =  20            
ENT.MaxDelay                         =  2            
ENT.TraceLength                      =  500           
ENT.ImpactSpeed                      =  500           
ENT.Mass                             =  0   
ENT.EnginePower                      =  0             
ENT.FuelBurnoutTime                  =  0             
ENT.IgnitionDelay                    =  0                        
ENT.RotationalForce                  =  25            
ENT.ArmDelay                         =  2             
ENT.ForceOrientation                 =  "NORMAL"
ENT.Timer                            =  0


ENT.LightEmitTime                    =  0
ENT.LightRed                         =  0
ENT.LightBlue						 =  0
ENT.LightGreen						 =  0
ENT.LightBrightness					 =  0
ENT.LightSize   					 =  0




ENT.GBOWNER                          =  nil             -- don't you fucking touch this.



function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)  
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType(MOVETYPE_VPHYSICS)
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Armed    = false
	 self.Exploded = false
	 self.Fired    = false
	 self.Burnt    = false
	 self.Ignition = false
	 self.Arming   = false
	 if !(WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "Arm", "Detonate", "Launch" }) end
	end
end

function ENT:TriggerInput(iname, value)
     if (!self:IsValid()) then return end
	 if (iname == "Detonate") then
         if (value >= 1) then
		     if (!self.Exploded and self.Armed) then
			     timer.Simple(math.Rand(0,self.MaxDelay),function()
				     if !self:IsValid() then return end
	                 self.Exploded = true
					 
			         self:Explode()
				 end)
		     end
		 end
	 end
	 if (iname == "Arm") then
         if (value >= 1) then
             if (!self.Exploded and !self.Armed and !self.Arming) then
			     self:EmitSound(self.ActivationSound)
                 self:Arm()
             end 
         end
     end		 
	 if (iname == "Launch") then 
	     if (value >= 1) then
		     if (!self.Exploded and !self.Burnt and !self.Ignition and !self.Fired) then
			     self:Launch()
		     end
	     end
     end
end          

function ENT:Explode()
     if not self.Exploded then return end
	 local pos = self:LocalToWorld(self:OBBCenter())
	 
	  	 local ent = ents.Create("gb5_shockwave_ent")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",self.ExplosionRadius)
	 ent:SetVar("SHOCKWAVE_INCREMENT",100)
	 ent:SetVar("DELAY",0.01)
	 ent.trace=self.TraceLength
	 ent.decal=self.Decal
	
	 local ent = ents.Create("gb5_shockwave_sound_lowsh")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",50000)
	if GetConVar("gb5_sound_speed"):GetInt() == 0 then
		ent:SetVar("SHOCKWAVE_INCREMENT",200)
	elseif GetConVar("gb5_sound_speed"):GetInt()== 1 then
		ent:SetVar("SHOCKWAVE_INCREMENT",300)
	elseif GetConVar("gb5_sound_speed"):GetInt() == 2 then
		ent:SetVar("SHOCKWAVE_INCREMENT",400)
	elseif GetConVar("gb5_sound_speed"):GetInt() == -1 then
		ent:SetVar("SHOCKWAVE_INCREMENT",100)
	elseif GetConVar("gb5_sound_speed"):GetInt() == -2 then
		ent:SetVar("SHOCKWAVE_INCREMENT",50)
	else
		ent:SetVar("SHOCKWAVE_INCREMENT",200)
	end
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", self.ExplosionSound)
	 ent:SetVar("Shocktime", self.Shocktime)
	 ent.RandomPitch=true
	 ent.Maxsounddist=10000

	 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius)) do
	     if v:IsValid() then
		     --local phys = v:GetPhysicsObject()
			 local i = 0
		     while i < v:GetPhysicsObjectCount() do
			 phys = v:GetPhysicsObjectNum(i)	  
             if (phys:IsValid()) then		
		 	     local mass = phys:GetMass()
				 local F_ang = self.PhysForce
				 local dist = (pos - v:GetPos()):Length()
				 local relation = math.Clamp((self.SpecialRadius - dist) / self.SpecialRadius, 0, 1)
				 local F_dir = (v:GetPos() - pos):GetNormal() * self.PhysForce
				   
				 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
				 phys:AddVelocity(F_dir)
		     end
			 i = i + 1
			 end
		 end
	 end
	 
     if(self:WaterLevel() >= 1) then
		 local trdata   = {}
		 local trlength = Vector(0,0,9000)

		 trdata.start   = pos
		 trdata.endpos  = trdata.start + trlength
		 trdata.filter  = self
		 local tr = util.TraceLine(trdata) 

		 local trdat2   = {}
		 trdat2.start   = tr.HitPos
		 trdat2.endpos  = trdata.start - trlength
		 trdat2.filter  = self
		 trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT
			 
		 local tr2 = util.TraceLine(trdat2)
			 
	     if tr2.Hit then
		     ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)   
		 end
     else
		 local tracedata    = {}
	     tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		 tracedata.filter   = self.Entity
				
		 local trace = util.TraceLine(tracedata)
	     
		 if trace.HitWorld then
		     ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)
		 else 
			 ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
		 end
     end
	 if self.IsNBC then
	     local nbc = ents.Create(self.NBCEntity)
		 nbc:SetVar("GBOWNER",self.GBOWNER)
		 nbc:SetPos(self:GetPos())
		 nbc:Spawn()
		 nbc:Activate()
	 end
	 self:Remove()
end

function ENT:OnTakeDamage(dmginfo)
     if !self:IsValid() then return end
     if self.Exploded then return end
	 if (self.Life <= 0) then return end
	 self:TakePhysicsDamage(dmginfo)
     if(GetConVar("gb5_fragility"):GetInt() >= 1) then  
	     if(!self.Fired and !self.Burnt and !self.Arming and !self.Armed) then
	         if(math.random(0,9) == 1) then
		         self:Launch()
		     else
			     self:Arm()
			 end
	     end
	 end
	 if(self.Fired and !self.Burnt and self.Armed) then
	     if (dmginfo:GetDamage() >= 2) then
		     local phys = self:GetPhysicsObject()
		     self:EmitSound(damagesound)
	         phys:AddAngleVelocity(dmginfo:GetDamageForce()*0.1)
	     end
	 end
	 if(!self.Armed) then return end
	 self.Life = self.Life - dmginfo:GetDamage()
     if (self.Life <= 0) then 
		 timer.Simple(math.Rand(0,self.MaxDelay),function()
	         if !self:IsValid() then return end 
			 self.Exploded = true
			 self:Explode()
			
	     end)
	 end
end

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 
	 if(GetConVar("gb5_fragility"):GetInt() >= 1) then
	     if(!self.Fired and !self.Burnt and !self.Arming and !self.Armed ) and (data.Speed > self.ImpactSpeed * 5) then --and !self.Arming and !self.Armed
		     if(math.random(0,9) == 1) then
			     self:Launch()
		         self:EmitSound(damagesound)
			 else
			     self:Arm()
				 self:EmitSound(damagesound)
			 end
	     end
	 end

	 if(!self.Armed) then return end
		
	 if (data.Speed > self.ImpactSpeed )then
		 self.Exploded = true
		 self:Explode()
	 end
end

function ENT:Launch()
     if(self.Exploded) then return end
	 if(self.Burned) then return end
	 --if(self.Armed) then return end
	 if(self.Fired) then return end
	 
	 local phys = self:GetPhysicsObject()
	 if !phys:IsValid() then return end
	 
	 self.Fired = true
	 if(self.SmartLaunch) then
		 constraint.RemoveAll(self)
	 end
	 timer.Simple(0.05,function()
	     if not self:IsValid() then return end
	     if(phys:IsValid()) then
             phys:Wake()
		     phys:EnableMotion(true)
	     end
	 end)
	 timer.Simple(self.IgnitionDelay,function()
	     if not self:IsValid() then return end  -- Make a short ignition delay!
		 self:SetNetworkedBool("Exploded",true)
		 self:SetNetworkedInt("LightRed", self.LightRed)
		 self:SetNetworkedInt("LightBlue", self.LightBlue)
		 self:SetNetworkedInt("LightGreen", self.LightGreen)	
		 self:SetNetworkedBool("EmitLight",true)
		 self:SetNetworkedInt("LightEmitTime", self.LightEmitTime)
		 self:SetNetworkedInt("LightBrightness", self.LightBrightness)
		 self:SetNetworkedInt("LightSize", self.LightSize)
		 local phys = self:GetPhysicsObject()
		 self.Ignition = true
		 self:Arm()
		 local pos = self:GetPos()
		 sound.Play(self.StartSound, pos, 160, 130,1)
	     self:EmitSound(self.EngineSound)
		 self:SetNetworkedBool("EmitLight",true)
		 self:SetNetworkedBool("self.Ignition",true)
		 ParticleEffectAttach(self.RocketTrail,PATTACH_ABSORIGIN_FOLLOW,self,1)
		 if(self.FuelBurnoutTime != 0) then 
	         timer.Simple(self.FuelBurnoutTime,function()
		         if not self:IsValid() then return end 
		         self.Burnt = true
		         self:StopParticles()
		         self:StopSound(self.EngineSound)
	             ParticleEffectAttach(self.RocketBurnoutTrail,PATTACH_ABSORIGIN_FOLLOW,self,1)
             end)	 
		 end
     end)		 
end

function ENT:Think()
     if(self.Burnt) then return end
     if(!self.Ignition) then return end -- if there wasn't ignition, we won't fly
	 if(self.Exploded) then return end -- if we exploded then what the fuck are we doing here
	 if(!self:IsValid()) then return end -- if we aren't good then something fucked up
	 local phys = self:GetPhysicsObject()  
	 local thrustpos = self:GetPos()
	 if(self.ForceOrientation == "RIGHT") then
	     phys:AddVelocity(self:GetRight() * self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "LEFT") then
	     phys:AddVelocity(self:GetRight() * -self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "UP") then
	     phys:AddVelocity(self:GetUp() * self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "DOWN") then 
	     phys:AddVelocity(self:GetUp() * -self.EnginePower) -- Continuous engine impulse
	 elseif(self.ForceOrientation == "INV") then
	     phys:AddVelocity(self:GetForward() * -self.EnginePower) -- Continuous engine impulse
	 else
		 phys:AddVelocity(self:GetForward() * self.EnginePower) -- Continuous engine impulse
	 end
	 if (self.Armed) then
        phys:AddAngleVelocity(Vector(self.RotationalForce,0,0)) -- Rotational force
	 end
	 
	 self:NextThink(CurTime() + 0.01)
	 return true
end

function ENT:Arm()
     if(!self:IsValid()) then return end
	 if(self.Armed) then return end
	 self.Arming = true
	 
	 timer.Simple(self.ArmDelay, function()
	     if not self:IsValid() then return end 
	     self.Armed = true
		 self.Arming = false
		 self:EmitSound(self.ArmSound)
		 if(self.Timed) then
	         timer.Simple(self.Timer, function()
	             if !self:IsValid() then return end 
			     self.Exploded = true
			     self:Explode()
				 self.EmitLight = true
	         end)
		 end
	 end)
end	 

function ENT:Use( activator, caller )
     if(self.Exploded) then return end
	 if(self.Dumb) then return end
	 if(GetConVar("gb5_easyuse"):GetInt() >= 1) then
         if(self:IsValid()) then
             if (!self.Exploded) and (!self.Burnt) and (!self.Fired) then
	             if (activator:IsPlayer()) then
                     self:EmitSound(self.ActivationSound)
                     self:Launch()
		         end
	         end
         end
	 end
end

function ENT:OnRemove()
     self:StopSound(self.EngineSound)
	 self:StopParticles()
end

if ( CLIENT ) then
     function ENT:Draw()
         self:DrawModel()
		 if !(WireAddon == nil) then Wire_Render(self.Entity) end
     end
end

function ENT:OnRestore()
     Wire_Restored(self.Entity)
end

function ENT:BuildDupeInfo()
     return WireLib.BuildDupeInfo(self.Entity)
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
     WireLib.ApplyDupeInfo( ply, ent, info, GetEntByID )
end

function ENT:PrentityCopy()
     local DupeInfo = self:BuildDupeInfo()
     if(DupeInfo) then
         duplicator.StorentityModifier(self.Entity,"WireDupeInfo",DupeInfo)
     end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
     if(Ent.EntityMods and Ent.EntityMods.WireDupeInfo) then
         Ent:ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, function(id) return CreatedEntities[id] end)
     end
end
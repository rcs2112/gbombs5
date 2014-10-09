AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_rocket_" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "HEM 19 - Tomahawk"
ENT.Author			                 =  ""
ENT.Contact			                 =  ""
ENT.Category                         =  "GB5: Missiles"

ENT.Model                            =  "models/military2/missile/missile_tomahawk3.mdl"
ENT.RocketTrail                      =  "tomahawk_trail"
ENT.RocketBurnoutTrail               =  ""
ENT.Effect                           =  "jdam_explosion_ground"
ENT.EffectAir                        =  "jdam_explosion_air"
ENT.EffectWater                      =  "water_torpedo" 
ENT.ExplosionSound                   =  "gbombs_5/launch/srb_explo.wav"        
ENT.StartSound                       =  "gbombs_5/launch/srb_launch.wav"          
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"    
ENT.EngineSound                      =  "Motor_Medium"

ENT.ShouldUnweld                     =  true          
ENT.ShouldIgnite                     =  true         
ENT.UseRandomSounds                  =  false         
ENT.SmartLaunch                      =  false
ENT.Timed                            =  false 

ENT.ExplosionDamage                  =  150
ENT.ExplosionRadius                  =  1250             
ENT.PhysForce                        =  1000             
ENT.SpecialRadius                    =  900            
ENT.MaxIgnitionTime                  =  2           
ENT.Life                             =  35            
ENT.MaxDelay                         =  0           
ENT.TraceLength                      =  600           
ENT.ImpactSpeed                      =  800         
ENT.Mass                             =  2500           
ENT.EnginePower                      =  10          
ENT.FuelBurnoutTime                  =  20           
ENT.IgnitionDelay                    =  2            
ENT.ArmDelay                         =  0.5
ENT.RotationalForce                  =  0                      
ENT.ForceOrientation                 =  "NONE"
ENT.Timer                            =  0
ENT.Shocktime                        = 3
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
	 self.Power    = 0.8
	 if !(WireAddon == nil) then self.Inputs = Wire_CreateInputs(self, { "Arm", "Detonate", "Launch" }) end
	end
end

function ENT:ExploSound(pos)
	 local ent = ents.Create("gb5_shockwave_sound_lowsh")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",500000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",20000)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", self.ExplosionSound)
	 ent:SetVar("Shocktime",4)
end

function ENT:Think()
     if(self.Burnt) then return end
     if(!self.Ignition) then return end -- if there wasn't ignition, we won't fly
	 if(self.Exploded) then return end -- if we exploded then what the fuck are we doing here
	 if(!self:IsValid()) then return end -- if we aren't good then something fucked up
	 if self.Power <= 1 then
		self.Power = self.Power + 0.01
	 elseif self.Power >=1 then
		self.Power = 1
	 end
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
		 phys:AddVelocity(self:GetForward() * (12*self.Power)) -- Continuous engine impulse
		 local vel = self:GetVelocity()
		 local vel_up = vel:Dot(self:GetForward())/100
		 if vel_up>14 then
			vel_up = 9
		 end
		 phys:AddVelocity(Vector(0,0, vel_up ))
		 
	 end
	 if (self.Armed) then
        phys:AddAngleVelocity(Vector(self.RotationalForce,0,0)) -- Rotational force
		
	 end
	 self:NextThink(CurTime() + 0.01)
	 return true
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
		 util.ScreenShake( self:GetPos(), 5555, 3555, 10, 500 )
		 util.ScreenShake( self:GetPos(), 5555, 555, 8, 500 )
		 util.ScreenShake( self:GetPos(), 5555, 555, 5, 500 )
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

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end
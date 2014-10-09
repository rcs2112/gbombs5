AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_rocket_" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "135mm Tankshell"
ENT.Author			                 =  ""
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/starchick971/tankshell.mdl"
ENT.RocketTrail                      =  "nebel_trail"
ENT.RocketBurnoutTrail               =  ""
ENT.Effect                           =  "high_explosive_main"
ENT.EffectAir                        =  "high_explosive_air" 
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "ambient/explosions/explode_1.wav"        
ENT.StartSound                       =  "gbombs_5/explosions/projectile/tankshell_01.wav"         
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  ""    
ENT.EngineSound                      =  "Missile.Ignite"  

ENT.ShouldUnweld                     =  true          
ENT.ShouldIgnite                     =  false         
ENT.UseRandomSounds                  =  true                  
ENT.SmartLaunch                      =  true  
ENT.Timed                            =  false 

ENT.ExplosionDamage                  =  150
ENT.ExplosionRadius                  =  250             
ENT.PhysForce                        =  300             
ENT.SpecialRadius                    =  225           
ENT.MaxIgnitionTime                  =  0           
ENT.Life                             =  25            
ENT.MaxDelay                         =  0           
ENT.TraceLength                      =  50          
ENT.ImpactSpeed                      =  100         
ENT.Mass                             =  100             
ENT.EnginePower                      =  9999999000           
ENT.FuelBurnoutTime                  =  0.23           
ENT.IgnitionDelay                    =  0.1           
ENT.ArmDelay                         =  0
ENT.RotationalForce                  =  500  
ENT.ForceOrientation                 =  "NORMAL"       
ENT.Timer                            =  0


ENT.DEFAULT_PHYSFORCE                = 155
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000     
ENT.Shocktime                        = 2

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

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


function ENT:Think() 
	 if !self:IsValid() then return end
     if(self.Burnt) then return end
     if(!self.Ignition) then return end -- if there wasn't ignition, we won't fly
	 if(self.Exploded) then return end -- if we exploded then what the fuck are we doing here
	 if(!self:IsValid()) then return end -- if we aren't good then something fucked up
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
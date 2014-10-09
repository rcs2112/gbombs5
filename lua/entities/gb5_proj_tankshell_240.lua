AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_rocket_" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "240mm Tankshell"
ENT.Author			                 =  ""
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/starchick971/tankshell_240.mdl"
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
ENT.ExplosionRadius                  =  450             
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
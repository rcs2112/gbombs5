AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Wildfire Barrel"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Misc"

ENT.Model                            =  "models/props/de_inferno/wine_barrel.mdl"                      
ENT.Effect                           =  "wildfire_fireball_explosion"                  
ENT.EffectAir                        =  "wildfire_fireball_explosion_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/heavy_bomb/ex1.wav"    

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  true
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  true
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  25         
ENT.PhysForce                        =  52           
ENT.ExplosionRadius                  =  2552           
ENT.SpecialRadius                    =  252            
ENT.MaxIgnitionTime                  =  7           
ENT.Life                             =  25       
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  65       
ENT.ImpactSpeed                      =  255          
ENT.Mass                             =  50

ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil     

ENT.DEFAULT_PHYSFORCE                = 2555
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000       
ENT.Decal                            = "scorch_big_2"
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
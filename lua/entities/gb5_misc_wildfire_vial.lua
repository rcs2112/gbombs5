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

ENT.PrintName		                 =  "Wildfire Vial"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Misc"

ENT.Model                            =  "models/thedoctor/wildfire.mdl"                      
ENT.Effect                           =  "neuro_wildfire_explo"                  
ENT.EffectAir                        =  "neuro_wildfire_explo_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/fieryexplosion.wav"    

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  true
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  25         
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  252           
ENT.SpecialRadius                    =  252            
ENT.MaxIgnitionTime                  =  4           
ENT.Life                             =  25       
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  65       
ENT.ImpactSpeed                      =  255          
ENT.Mass                             =  50

ENT.DEFAULT_PHYSFORCE                = 50
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000 

ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil           

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
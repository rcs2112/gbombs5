AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  false        
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "CBU-52U Bomblet"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "Garry's Bombs 5"

ENT.Model                            =  "models/thedoctor/davy_propellant.mdl"                      
ENT.Effect                           =  "high_explosive_air"                  
ENT.EffectAir                        =  "high_explosive_air_2"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/medium_bomb/explosion_medium.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  99
ENT.PhysForce                        =  600
ENT.ExplosionRadius                  =  300
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  98                                 
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  110
ENT.Mass                             =  90
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil 

ENT.DEFAULT_PHYSFORCE                = 255
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 1000 
ENT.Decal                            = "scorch_small"
function ENT:ExploSound(pos)
     if not self.Exploded then return end
	 if self.UseRandomSounds then
         sound.Play(table.Random(ExploSnds), pos, 160, 100,1)
     else
	     sound.Play(self.ExplosionSound, pos, 160, 100,1)
	 end
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
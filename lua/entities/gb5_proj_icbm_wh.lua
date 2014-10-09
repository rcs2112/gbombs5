AddCSLuaFile()


DEFINE_BASECLASS( "gb5_base_dumb" )




ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "ICBM Warhead"
ENT.Author			                 =  ""
ENT.Contact			                 =  ""
ENT.Category                         =  "GB5: Custom Nukes"

ENT.Model                            =  "models/thedoctor/icbm/capsule.mdl"           
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""   
ENT.EffectWater                      =  "" 
ENT.ExplosionSound                   =  ""                   
ENT.ParticleTrail                    =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false      
ENT.ShouldExplodeOnImpact            =  false         
ENT.Flamable                         =  false        
ENT.UseRandomSounds                  =  false       
ENT.UseRandomModels                  =  false

ENT.ExplosionDamage                  =  1          
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  3           
ENT.SpecialRadius                    =  4            
ENT.MaxIgnitionTime                  =  1           
ENT.Life                             =  500          
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  0        
ENT.ImpactSpeed                      =  0           
ENT.Mass                             =  2500

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

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

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * -600 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end
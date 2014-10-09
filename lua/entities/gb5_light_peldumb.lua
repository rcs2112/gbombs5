AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )


ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "Pellet"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  ""

ENT.Model                            =  "models/thedoctor/pellet.mdl"           
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
ENT.Life                             =  2555         
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  0        
ENT.ImpactSpeed                      =  2555         
ENT.Mass                             =  155

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.


function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
     ent:SetPos( tr.HitPos + tr.HitNormal * 25 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end
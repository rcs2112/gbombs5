AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )


ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Atomic Annie"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/thedoctor/atomicannie.mdl"           
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
ENT.Mass                             =  5000

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:SetupBase(tank)
	 local wheelspinvec = Vector(-1000,0,0)
	 local selfpos = tank:GetPos()
	 
	 local base = ents.Create("prop_physics")
	 base:SetPos(selfpos + Vector(20.75,8,-80))
	 base:SetAngles(Angle(0,0,0))
	 base:SetModel("models/thedoctor/atomicanniebase.mdl")
	 base:Spawn()
	 base:Activate()
	 self.baseowner = base
	 local phys = base:GetPhysicsObject()
	 if (phys:IsValid()) then
		 phys:SetMass(15000)
		 phys:Wake()
	 end
	 local ent = ents.Create("gb5_nuclear_grable")
	 ent:SetAngles(Angle(0,0,0))
	 ent:Spawn()
	 ent:Activate()
	 ent:SetPos(self:GetPos() + Vector(-11,-40,17))
	 ent:SetAngles(self:GetAngles())
	 ent:SetParent( self )
	 self.shell=ent
	 
	 local ent = ents.Create("gb5_nuclear_propellant")
	 ent:SetAngles(Angle(0,0,0))
	 ent:Spawn()
	 ent:Activate()
	 ent:SetPos(self:GetPos() + Vector(-11,-50,17))
	 ent:SetAngles(self:GetAngles()-Angle(0,0,90))
	 ent:SetParent( self )
	 self.prop=ent
	 if self:IsValid() then
	     constraint.Axis(base,tank,0,0,Vector(0,0,80),selfpos,0,0,0,0,wheelspinvec)
	 end
end

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 96 ) 
     ent:Spawn()
     ent:Activate()
	 ent:SetupBase(ent)
     return ent
end

function ENT:OnRemove()
	if SERVER then
		if self.baseowner:IsValid() then
			self.baseowner:Remove()
		end
		if self.shell:IsValid() then
			self.shell:Remove()
		end
		if self.prop:IsValid() then
			self.prop:Remove()
		end
	end
end

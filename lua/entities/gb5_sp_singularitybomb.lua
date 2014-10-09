AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Singularity Bomb"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Specials"

ENT.Model                            =  "models/thedoctor/mutagenbomb.mdl"                      
ENT.Effect                           =  "redmatter_main"                  
ENT.EffectAir                        =  "redmatter_main"                   
ENT.EffectWater                      =  "water_medium"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     
ENT.ExplosionSound                   =  ""       
ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  0
ENT.PhysForce                        =  600
ENT.ExplosionRadius                  =  950
ENT.SpecialRadius                    =  1275
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  300
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end 
	 if(self.Dumb) then
	     self.Armed    = true
	 else
	     self.Armed    = false
	 end
	 self.Exploded = false
	 self.Used     = false
	 self.Arming = false
	 self.Exploding = false
	 self.EventHorizon = 1
	  if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end



function ENT:Explode()
     if !self.Exploded then return end
	 if self.Exploding then return end
	
	 local pos = self:LocalToWorld(self:OBBCenter())
	 self:SetModel("models/gibs/scanner_gib02.mdl")

	 self.Exploding = true
	 local physo = self:GetPhysicsObject()
	 physo:Wake()
	 physo:EnableMotion(true)
	 pos_cache = self:GetPos()
	 self:SetMoveType( MOVETYPE_NONE )
	 self:SetMaterial("phoenix_storms/glass")
	 self:SetModel("models/hunter/plates/plate.mdl")
  	 timer.Simple(5, function()
	     if !self:IsValid() then return end 
				
			 local ent = ents.Create("gb5_shockwave_sin")
			 ent:SetPos( pos_cache ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",24000)
			 ent:SetVar("SHOCKWAVE_INCREMENT",65)
			 ent:SetVar("DELAY",0.1)

			 
			 local ent = ents.Create("gb5_shockwave_sound_lowsh")
			 ent:SetPos( pos_cache ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",500000)
			 ent:SetVar("SHOCKWAVE_INCREMENT",20000)
			 ent:SetVar("DELAY",0.01)
			 ent:SetVar("SOUND", "gbombs_5/explosions/special/singularity_bomb.wav")
			 ent:SetVar("Shocktime",40)

			 
			 self:SetModel("models/gibs/scanner_gib02.mdl")
			 self.Exploding = true
     end)
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
			 ParticleEffect("singularity_main",pos,Angle(0,0,0),nil)	
			 timer.Simple(5, function()
				 if !self:IsValid() then return end 
				 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
				 self:Remove()
		 end)	
		 else 
			 ParticleEffect("singularity_main",pos,Angle(0,0,0),nil) 		
			 timer.Simple(5, function()
			 if !self:IsValid() then return end 
				self:Remove()
			 end)
		 end
	 end
end
function ENT:OnRemove()
	self:StopParticles()
end
function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 36 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end
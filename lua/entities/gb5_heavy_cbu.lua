AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "CBU-52U"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Heavy Bombs"

ENT.Model                            =  "models/military2/bomb/bomb_cbu.mdl"                      
ENT.Effect                           =  "high_explosive_main_2"                  
ENT.EffectAir                        =  "high_explosive_air_2"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_extra/explosions/light_bomb/mine_explosion.wav"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  200
ENT.PhysForce                        =  200
ENT.ExplosionRadius                  =  100
ENT.SpecialRadius                    =  500
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  0                                 
ENT.TraceLength                      =  3000
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  52
ENT.ArmDelay                         =  0  
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.


ENT.DEFAULT_PHYSFORCE                = 155
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000 

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
	  if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

function ENT:Explode()
     if !self.Exploded then return end
	 if self.Exploding then return end
	
	 local pos = self:LocalToWorld(self:OBBCenter())
	
	 constraint.RemoveAll(self)
	 local physo = self:GetPhysicsObject()
	 physo:Wake()	
	 self.Exploding = true
	 if !self:IsValid() then return end 
	 self:StopParticles()
	 local pos = self:LocalToWorld(self:OBBCenter())
	 
	 local ent = ents.Create("gb5_shockwave_ent")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",self.ExplosionRadius)
	 ent:SetVar("SHOCKWAVE_INCREMENT",100)
	 ent:SetVar("DELAY",0.01)
	
	 local ent = ents.Create("gb5_shockwave_sound_lowsh")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",50000)
	if GetConVar("gb5_sound_speed"):GetInt() == 0 then
		ent:SetVar("SHOCKWAVE_INCREMENT",200)
	elseif GetConVar("gb5_sound_speed"):GetInt()== 1 then
		ent:SetVar("SHOCKWAVE_INCREMENT",300)
	elseif GetConVar("gb5_sound_speed"):GetInt() == 2 then
		ent:SetVar("SHOCKWAVE_INCREMENT",400)
	elseif GetConVar("gb5_sound_speed"):GetInt() == -1 then
		ent:SetVar("SHOCKWAVE_INCREMENT",100)
	elseif GetConVar("gb5_sound_speed"):GetInt() == -2 then
		ent:SetVar("SHOCKWAVE_INCREMENT",50)
	else
		ent:SetVar("SHOCKWAVE_INCREMENT",200)
	end
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", self.ExplosionSound)
	 ent:SetVar("Shocktime", self.Shocktime)

	 for i=0, (15-1) do
		 local ent1 = ents.Create("gb5_heavy_cbu_bomblet") 
		 local phys = ent1:GetPhysicsObject()
		 ent1:SetPos( self:GetPos() ) 
		 ent1:Spawn()
		 ent1:Activate()
		 ent1:SetVar("GBOWNER", self.GBOWNER)
		 local bphys = ent1:GetPhysicsObject()
		 local phys = self:GetPhysicsObject()
		 if bphys:IsValid() and phys:IsValid() then
			 bphys:ApplyForceCenter(VectorRand() * bphys:GetMass() * 155)
			 bphys:AddVelocity(phys:GetVelocity()/2)
		 end
		 timer.Simple(4, function()
		    if ent1:IsValid() then
				ent1:Remove()
			end
		 end)
	 end
	 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius/2)) do
		 if self.ShouldUnweld then
			 if v:IsValid() then
				 if v:IsValid() and v:GetPhysicsObject():IsValid() then
					 constraint.RemoveAll(v)
				 end
			 end
		 end
		 if self.ShouldIgnite then
			 if v:IsOnFire() then
				 v:Extinguish()
			 end
			 v:Ignite(math.Rand(self.MaxIgnitionTime-2,self.MaxIgnitionTime),5)
		 end
	 end
	 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius)) do
		 if v:IsValid() && (v != self) then
			 local phys = v:GetPhysicsObject()
			 if (phys:IsValid()) then
				 local mass = phys:GetMass()
				 local F_ang = self.PhysForce
				 local dist = (pos - v:GetPos()):Length()
				 local relation = math.Clamp((self.SpecialRadius - dist) / self.SpecialRadius, 0, 1)
				 local F_dir = (v:GetPos() - pos):GetNormal() * self.PhysForce
		
				 phys:Wake()
				 phys:EnableMotion(true)
			   
				 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
				 phys:AddVelocity(F_dir)
			 end
		 end
	 end 
	 local pos = self:GetPos()
	 util.BlastDamage(self, self.GBOWNER, pos, self.ExplosionRadius, self.ExplosionDamage)
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
			 ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)	
			 timer.Simple(0.1, function()
				 if !self:IsValid() then return end 
				 self:Remove()
				 
			 end)
		 else 
			 ParticleEffect(self.EffectAir,self:GetPos(),Angle(0,0,0),nil) 
			 if !self:IsValid() then return end 
				self:Remove()
		 end
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
AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true     
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Tsar Bomba"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Nuclear"

ENT.Model                            =  "models/thedoctor/tsar.mdl"                      
ENT.Effect                           =  "tsar_bomba_ground"                  
ENT.EffectAir                        =  "tsar_bomba_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/nuclear/tsar_detonate.wav"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.ExplosionRadius                  =  35000
ENT.SpecialRadius                    =  5000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  1000
ENT.ImpactSpeed                      =  1300
ENT.Mass                             =  18500
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.
ENT.Decal                            = "nuke_tsar"
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

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 if(data.Speed > 200) then
		self:EmitSound("gbombs_5/arm/tsarland.wav", 80, math.random(90,110))
	 end
	 if(GetConVar("gb5_fragility"):GetInt() >= 1) then
	     if(data.Speed > self.ImpactSpeed) then
	 	     if(!self.Armed and !self.Arming) then

	             self:Arm()
	         end
		 end
	 end
	 if(!self.Armed) then return end
     if self.ShouldExplodeOnImpact then
	     if (data.Speed > self.ImpactSpeed ) then
			 self.Exploded = true
			 self:Explode()
		 end
	 end
end

function ENT:Explode()
     if !self.Exploded then return end
	 if self.Exploding then return end
	
	 local pos = self:LocalToWorld(self:OBBCenter())
	 local ent = ents.Create("gb5_shockwave_ent")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",35000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",100)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("DEFAULT_PHYSFORCE", 955)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 15)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 155)
	 ent.trace=self.TraceLength
	 ent.decal=self.Decal
	if GetConVar("gb5_nuclear_fallout"):GetInt()== 1 then
		local ent = ents.Create("gb5_base_radiation_draw_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent.Burst = 50
		ent.RadRadius=35000
		
		local ent = ents.Create("gb5_base_radiation_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent.Burst = 50
		ent.RadRadius=35000
	 end			 
	 local ent = ents.Create("gb5_shockwave_rumbling")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",50000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",5000)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/tsar_in.mp3")
	
	 local ent = ents.Create("gb5_shockwave_rumbling")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",35000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",150)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", self.ExplosionSound)
	 
	 local ent = ents.Create("gb5_shockwave_sound_burst")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",50000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",100)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", self.ExplosionSound)

	 local ent = ents.Create("gb5_shockwave_sound_lowsh")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",50000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",100)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/tsar_detonate.wav")
	 self:SetModel("models/gibs/scanner_gib02.mdl")
	 self.Exploding = true
	
	 local physo = self:GetPhysicsObject()
	 physo:Wake()
	 physo:EnableMotion(true)
	 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius*3)) do
		 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
			if v:IsValid() and v:GetPhysicsObject():IsValid() then
				v:Ignite(4,0)
			end
		 end
	 end
	 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius)) do
		if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
			if v:IsPlayer() && v:Alive() then
			    v:SetModel("models/Humans/Charple04.mdl")
				v:Kill()
			end
		 end
	 end
	
  	 timer.Simple(2, function()
	     if !self:IsValid() then return end 
		 constraint.RemoveAll(self)
		 util.ScreenShake( pos, 55555, 255, 10, 121000 )
		 self:StopParticles()
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
		         ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)	
			     timer.Simple(2, function()
			         if !self:IsValid() then return end 
			         ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
				     self:Remove()
             end)	
		     else 
			     ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
				 --Here we do an emp check
				 timer.Simple(2, function()
					 if !self:IsValid() then return end 
					 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
					 self:Remove()
				end)	
				if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
					 local ent = ents.Create("gb5_emp_entity")
					 ent:SetPos( self:GetPos() ) 
					 ent:Spawn()
					 ent:Activate()	
				 end
		     end
		 end
end

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 56 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end
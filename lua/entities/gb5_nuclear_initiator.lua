AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Nuclear Initiator"
ENT.Author			                 =  "Rogue"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Custom Nukes"

ENT.Model                            =  "models/Items/AR2_Grenade.mdl"                      
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/nuclear/fat_explosion.mp3"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  1
ENT.PhysForce                        =  1
ENT.ExplosionRadius                  =  1
ENT.SpecialRadius                    =  1
ENT.MaxIgnitionTime                  =  1
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  1000
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  100
ENT.ArmDelay                         =  1   
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
	  if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

function ENT:Explode()
	 self.uranium_mul   = 0
	 self.plutonium_mul = 0
	 self.tritium_mul   = 0 
     if !self.Exploded then return end
	 if self.Exploding then return end
	
	 local pos = self:LocalToWorld(self:OBBCenter())
	 self:SetModel("models/gibs/scanner_gib02.mdl")
	 self.Exploding = true
	 for k, v in pairs(ents.FindInSphere(pos,200)) do -- Here we do an initial count
		 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
			if v:GetClass() == "gb5_nuclear_c_uranium" then
				self.uranium_mul = self.uranium_mul + 1
				v:Remove()
			end
			if v:GetClass() == "gb5_nuclear_c_plutonium" then
				self.plutonium_mul = self.plutonium_mul + 1
				v:Remove()
			end
			if v:GetClass() == "gb5_nuclear_c_tritium" then
				self.tritium_mul = self.tritium_mul + 1
				v:Remove()
			end
		 end
	 end
	 if self.uranium_mul == 0 then -- No fission = no explosion
		self:Remove()
	
	 end
	if (self.uranium_mul==1) or (self.uranium_mul == 2) then -- Then we have a fizzure! (Davy Crockett)
	
		local pos = self:LocalToWorld(self:OBBCenter())
		self:SetModel("models/gibs/scanner_gib02.mdl")
		self.Exploding = true

		local ent = ents.Create("gb5_shockwave_sound_instant")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("MAX_BURSTS", 1)
		ent:SetVar("MAX_RANGE",50000)
		ent:SetVar("DELAY",0.1)
		ent:SetVar("sound", "gbombs_5/explosions/nuclear/tsar_in.mp3")
		ent:SetVar("Shocktime",1)

		local ent = ents.Create("gb5_shockwave_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",2000*self.uranium_mul)
		ent:SetVar("SHOCKWAVE_INCREMENT",100)
		ent:SetVar("DELAY",0.01)
		ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/abomb.mp3")
		ent.trace=500
		ent.decal="nuke_small"
		 
		local ent = ents.Create("gb5_shockwave_rumbling")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",6000)
		ent:SetVar("SHOCKWAVE_INCREMENT",200)
		ent:SetVar("DELAY",0.01)
		
		local ent = ents.Create("gb5_shockwave_sound_lowsh")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",50000)
		ent:SetVar("SHOCKWAVE_INCREMENT", 100)
		ent:SetVar("DELAY",0.01)
		ent:SetVar("shocktime", 4)
		ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/davy_explosion.wav")
		
		local ent = ents.Create("gb5_base_radiation_draw_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent.Burst = 25
		ent.RadRadius=2000*self.uranium_mul
		
		local ent = ents.Create("gb5_base_radiation_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent.Burst = 25
		ent.RadRadius=2000*self.uranium_mul
		local physo = self:GetPhysicsObject()
		physo:Wake()
		physo:EnableMotion(true)
		for k, v in pairs(ents.FindInSphere(pos,2000)) do
			if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsValid() and v:GetPhysicsObject():IsValid() then
					v:Ignite(4,0)
				end
			end
		 end
		 for k, v in pairs(ents.FindInSphere(pos,500)) do
			if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsPlayer() && !v:IsNPC() then
					v:SetModel("models/Humans/Charple04.mdl")
					ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0) 
					v:Kill()
				end
			end
		 end
		 if !self:IsValid() then return end  
		 self:SetModel("models/gibs/scanner_gib02.mdl")
		 self.Exploding = true
		 self:StopParticles()
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
			tracedata.endpos   = tracedata.start - Vector(0, 0, 500)
			tracedata.filter   = self.Entity

			local trace = util.TraceLine(tracedata)
			 
			if trace.HitWorld then
				 ParticleEffect("davycrockett_main",pos,Angle(0,0,0),nil)	
				 self:Remove()
			else 
				ParticleEffect("davycrockett_air",pos,Angle(0,0,0),nil) 
				self:Remove()
				if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
					local ent = ents.Create("gb5_emp_entity")
					ent:SetPos( self:GetPos() ) 
					ent:Spawn()
					ent:Activate()	
				end
			end
		end
	elseif (self.uranium_mul>=3) and (self.uranium_mul<=6) then -- Then we have fission! 
		for k, v in pairs(ents.FindInSphere(pos,1500*self.uranium_mul)) do
			 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsValid() and v:GetPhysicsObject():IsValid() then
					v:Ignite(4,0)
				end
			 end
		 end
		 for k, v in pairs(ents.FindInSphere(pos,2000)) do
			if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsPlayer() && !v:IsNPC() then
					v:SetModel("models/Humans/Charple04.mdl")
					ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0) 
					v:Kill()
				end
			 end
		 end
		
		 timer.Simple(2, function()
			 if !self:IsValid() then return end 
			 local ent = ents.Create("gb5_shockwave_ent")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
			 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
			 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",1500*self.uranium_mul)
			 ent:SetVar("SHOCKWAVE_INCREMENT",100)
			 ent:SetVar("DELAY",0.01)
			 ent.trace=1000
			 ent.decal="nuke_medium"

			 local ent = ents.Create("gb5_shockwave_rumbling")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",2250*self.uranium_mul)
			 ent:SetVar("SHOCKWAVE_INCREMENT",200)
			 ent:SetVar("DELAY",0.01)
			 
			 local ent = ents.Create("gb5_shockwave_sound_burst")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",50000)
			 ent:SetVar("SHOCKWAVE_INCREMENT",100)
			 ent:SetVar("DELAY",0.01)
			
			 local ent = ents.Create("gb5_shockwave_sound_lowsh")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",12000)
			 ent:SetVar("SHOCKWAVE_INCREMENT",100)
			 ent:SetVar("DELAY",0.01)
			 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/abomb.mp3")
			 self.Exploding = true
		
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
			 tracedata.endpos   = tracedata.start - Vector(0, 0, 1000)
			 tracedata.filter   = self.Entity
				
			 local trace = util.TraceLine(tracedata)
		 
			 if trace.HitWorld then
				 ParticleEffect("littleboy_main",pos,Angle(0,0,0),nil)	
				 timer.Simple(2, function()
					 if !self:IsValid() then return end 
					 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
					 self:Remove()
			 end)	
			 else 
				 ParticleEffect("littleboy_air_main",pos,Angle(0,0,0),nil) 
				 timer.Simple(2, function()
					 if !self:IsValid() then return end 
					 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
					 self:Remove()
				end)	
				 --Here we do an emp check
				if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
					 local ent = ents.Create("gb5_emp_entity")
					 ent:SetPos( self:GetPos() ) 
					 ent:Spawn()
					 ent:Activate()	
				 end
			 end
		 end
	elseif (self.uranium_mul>=7 && self.uranium_mul<=10) and (self.plutonium_mul >= 1 && self.plutonium_mul <=2) then -- Then we have fission! 	
		for k, v in pairs(ents.FindInSphere(pos,900*self.uranium_mul)) do
			 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
					v:Ignite(4,0)
				end
			 end
		 end
		 for k, v in pairs(ents.FindInSphere(pos,2500)) do
			if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsPlayer() then
					v:SetModel("models/Humans/Charple04.mdl")
					v:Kill()
				end
			 end
		 end
		
		 timer.Simple(2, function()
			 if !self:IsValid() then return end 
			 local ent = ents.Create("gb5_shockwave_ent")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
			 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
			 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",(900*self.uranium_mul)+(150*self.plutonium_mul))
			 ent:SetVar("SHOCKWAVE_INCREMENT",180)
			 ent:SetVar("DELAY",0.01)
			 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/nuke_after.wav")
			 ent.trace=1500
			 ent.decal="nuke_medium"
			 
			 
			 local ent = ents.Create("gb5_shockwave_rumbling")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",10000)
			 ent:SetVar("SHOCKWAVE_INCREMENT",260)
			 ent:SetVar("DELAY",0.01)
			 self:SetModel("models/gibs/scanner_gib02.mdl")
			 
			 local ent = ents.Create("gb5_shockwave_sound_burst")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",50000)
			 ent:SetVar("SHOCKWAVE_INCREMENT",180)
			 ent:SetVar("DELAY",0.01)
			 ent:SetVar("SOUND", self.ExplosionSound)
			 self:SetModel("models/gibs/scanner_gib02.mdl")
			 
			 local ent = ents.Create("gb5_shockwave_sound_lowsh")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",13000)
			 ent:SetVar("SHOCKWAVE_INCREMENT",180)
			 ent:SetVar("DELAY",0.01)
			 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/nuke_trinity.wav")
			 
			 self.Exploding = true
			 constraint.RemoveAll(self)
			 util.ScreenShake( pos, 5555, 555, 10, 81000 )
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
				 tracedata.endpos   = tracedata.start - Vector(0, 0, 1500)
				 tracedata.filter   = self.Entity
					
				 local trace = util.TraceLine(tracedata)
			 
				 if trace.HitWorld then
					 ParticleEffect("trinity_main",pos,Angle(0,0,0),nil)	
					 timer.Simple(2, function()
						 if !self:IsValid() then return end 
						 self:Remove()
				 end)	
				 else 
					 ParticleEffect("trinity_air",pos,Angle(0,0,0),nil) 
					 
					 --Here we do an emp check
				if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
					 local ent = ents.Create("gb5_emp_entity")
					 ent:SetPos( self:GetPos() ) 
					 ent:Spawn()
					 ent:Activate()	
				 end
				 timer.Simple(2, function()
					if !self:IsValid() then return end
					self:Remove()
				 end)
			 end
		end
	elseif (self.uranium_mul>=11 && self.uranium_mul<=15) and (self.plutonium_mul >= 3 && self.plutonium_mul <=5) then 
		 local ent = ents.Create("gb5_shockwave_ent")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
		 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
		 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",(666*self.uranium_mul)+(150*self.plutonium_mul))
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)
		 self:SetModel("models/gibs/scanner_gib02.mdl")
		 ent.trace=1500
		 ent.decal="nuke_medium"
		 
		 local ent = ents.Create("gb5_shockwave_rumbling")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",11000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",200)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)

		 
		 local ent = ents.Create("gb5_shockwave_sound_burst")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",45000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)

		 local ent = ents.Create("gb5_shockwave_sound_lowsh")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",15000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)
		 self:SetModel("models/gibs/scanner_gib02.mdl")

		 self.Exploding = true

		 local physo = self:GetPhysicsObject()
		 physo:Wake()
		 physo:EnableMotion(true)
		 for k, v in pairs(ents.FindInSphere(pos,(300*self.uranium_mul)*3)) do
			 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsValid() and v:GetPhysicsObject():IsValid() then
					v:Ignite(4,0)
				end
			 end
		 end
		 for k, v in pairs(ents.FindInSphere(pos,300*self.uranium_mul)) do
			if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsPlayer() && !v:IsNPC() then
					v:SetModel("models/Humans/Charple04.mdl")
					v:Kill()
				end
			 end
		 end

		 timer.Simple(2, function()
			 if !self:IsValid() then return end 
			 constraint.RemoveAll(self)
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
			 tracedata.endpos   = tracedata.start - Vector(0, 0, 1500)
			 tracedata.filter   = self.Entity
				
			 local trace = util.TraceLine(tracedata)
		 
			 if trace.HitWorld then
				 ParticleEffect("fatman_main",pos,Angle(0,0,0),nil)	
				 timer.Simple(2, function()
					 if !self:IsValid() then return end 
					 self:Remove()
			 end)	
			 else 
				 ParticleEffect("fatman_air",pos,Angle(0,0,0),nil) 
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
	elseif (self.uranium_mul>=16 && self.uranium_mul<=20) and (self.plutonium_mul >= 6 && self.plutonium_mul <=10) and (self.tritium_mul >= 1 && self.tritium_mul <=2) then 
		 local pos = self:LocalToWorld(self:OBBCenter())
		 local ent = ents.Create("gb5_shockwave_ent")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",(900*self.uranium_mul)+(150*self.plutonium_mul)+(300*self.tritium_mul))
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/abomb.mp3")
		 ent.trace=2000
		 ent.decal="nuke_big"
			 
		 local ent = ents.Create("gb5_shockwave_rumbling")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",19000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",200)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)
		 
		 local ent = ents.Create("gb5_shockwave_sound_burst")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",35000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)

		 local ent = ents.Create("gb5_shockwave_sound_lowsh")	 
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",21000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/fat_explosion.mp3")
		 
		 for k, v in pairs(ents.FindInSphere(pos,(self.uranium_mul*250)*3)) do
			 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsValid() and v:GetPhysicsObject():IsValid() then
					v:Ignite(4,0)
				end
			 end
		 end
		 for k, v in pairs(ents.FindInSphere(pos,self.uranium_mul*250)) do
			if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsPlayer() then
					v:SetModel("models/Humans/Charple04.mdl")
					v:Kill()
				end
			 end
		 end
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
			 tracedata.endpos   = tracedata.start - Vector(0, 0, 2000)
			 tracedata.filter   = self.Entity
				
			 local trace = util.TraceLine(tracedata)
		 
			 if trace.HitWorld then
				 ParticleEffect("highyield_nuke_ground_main",pos,Angle(0,0,0),nil)	
				 timer.Simple(2, function()
					 if !self:IsValid() then return end 
					 self:Remove()
			 end)	
			 else 
				 ParticleEffect("highyield_nuke_air_main",pos,Angle(0,0,0),nil) 
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
	elseif (self.uranium_mul>=21 && self.uranium_mul<=50) and (self.plutonium_mul >= 11 && self.plutonium_mul <=50) and (self.tritium_mul >= 3 && self.tritium_mul <=50) then 
		 local pos = self:LocalToWorld(self:OBBCenter())
		 local ent = ents.Create("gb5_shockwave_ent")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",(900*self.uranium_mul)+(150*self.plutonium_mul)+(300*self.tritium_mul))
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/abomb.mp3")
		 ent.trace=2000
		 ent.decal="nuke_tsar"
			 
		 local ent = ents.Create("gb5_shockwave_rumbling")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",19000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",200)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)
		 
		 local ent = ents.Create("gb5_shockwave_sound_burst")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",35000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)

		 local ent = ents.Create("gb5_shockwave_sound_lowsh")	 
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent:SetVar("MAX_RANGE",21000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",100)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/fat_explosion.mp3")
		 
		 for k, v in pairs(ents.FindInSphere(pos,(self.uranium_mul*250)*3)) do
			 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsValid() and v:GetPhysicsObject():IsValid() then
					v:Ignite(4,0)
				end
			 end
		 end
		 for k, v in pairs(ents.FindInSphere(pos,self.uranium_mul*250)) do
			if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
				if v:IsPlayer() then
					v:SetModel("models/Humans/Charple04.mdl")
					v:Kill()
				end
			 end
		 end
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
			 tracedata.endpos   = tracedata.start - Vector(0, 0, 2000)
			 tracedata.filter   = self.Entity
				
			 local trace = util.TraceLine(tracedata)
		 
			 if trace.HitWorld then
				 ParticleEffect("tsar_bomba_ground",pos,Angle(0,0,0),nil)	
				 timer.Simple(2, function()
					 if !self:IsValid() then return end 
					 self:Remove()
			 end)	
			 else 
				 timer.Simple(2, function()
					 if !self:IsValid() then return end 
					 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
					 self:Remove()
				end)				 
				 ParticleEffect("tsar_bomba_air",pos,Angle(0,0,0),nil) 
				 --Here we do an emp check
				 if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
					 local ent = ents.Create("gb5_emp_entity")
					 ent:SetPos( self:GetPos() ) 
					 ent:Spawn()
					 ent:Activate()	
				 end
			 end
		 end
	else
		self:Remove()
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
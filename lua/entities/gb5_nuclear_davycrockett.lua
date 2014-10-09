AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Davy Crockett"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Artillery"

ENT.Model                            =  "models/thedoctor/davy.mdl"                      
ENT.Effect                           =  "davycrockett_main"                  
ENT.EffectAir                        =  "davycrockett_air"                   
ENT.EffectWater                      =  "water_huge"
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
ENT.ExplosionRadius                  =  8000
ENT.SpecialRadius                    =  2000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  255
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.DEFAULT_PHYSFORCE                = 255
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 25
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 2555
ENT.GBOWNER                          =  nil     
ENT.Decal                            = "nuke_small"

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


if SERVER then
	function ENT:Explode()
		 if !self.Exploded then return end
		 if self.Exploding then return end
		
		 local pos = self:LocalToWorld(self:OBBCenter())
		 self:SetModel("models/gibs/scanner_gib02.mdl")
		 self.Exploding = true
		 
		 local ent = ents.Create("gb5_shockwave_sound_instant")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
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
		 ent:SetVar("MAX_RANGE",4000)
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
		 ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/abomb.mp3")
		 ent.trace=self.TraceLength
		 ent.decal=self.Decal
		 
		local ent = ents.Create("gb5_shockwave_rumbling")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",12000)
		if GetConVar("gb5_sound_speed"):GetInt() == 0 then
			ent:SetVar("SHOCKWAVE_INCREMENT",300)
		elseif GetConVar("gb5_sound_speed"):GetInt()== 1 then
			ent:SetVar("SHOCKWAVE_INCREMENT",400)
		elseif GetConVar("gb5_sound_speed"):GetInt() == 2 then
			ent:SetVar("SHOCKWAVE_INCREMENT",500)
		elseif GetConVar("gb5_sound_speed"):GetInt() == -1 then
			ent:SetVar("SHOCKWAVE_INCREMENT",200)
		elseif GetConVar("gb5_sound_speed"):GetInt() == -2 then
			ent:SetVar("SHOCKWAVE_INCREMENT",100)
		else
			ent:SetVar("SHOCKWAVE_INCREMENT",300)
		end
		ent:SetVar("DELAY",0.01)
		ent:SetVar("SOUND", self.ExplosionSound)
		self:SetModel("models/gibs/scanner_gib02.mdl")
		constraint.RemoveAll(self)

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
		ent:SetVar("shocktime", 4)
		ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/davy_explosion.wav")
		if GetConVar("gb5_nuclear_fallout"):GetInt()== 1 then
			local ent = ents.Create("gb5_base_radiation_draw_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent.Burst = 25
			ent.RadRadius=3000
			
			local ent = ents.Create("gb5_base_radiation_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent.Burst = 25
			ent.RadRadius=3000
		 end
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
		 for k, v in pairs(ents.FindInSphere(pos,350)) do
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
			 tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
			 tracedata.filter   = self.Entity
				
			 local trace = util.TraceLine(tracedata)
		 
			if trace.HitWorld then
				 ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)	
				 timer.Simple(1, function()
					 if !self:IsValid() then return end 
					 self:Remove()
				end)	
			else 
				 ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
				 self:Remove()
				 if(GetConVar("gb5_nuclear_emp"):GetInt() >= 1) then
					 local ent = ents.Create("gb5_emp_entity")
					 ent:SetPos( self:GetPos() ) 
					 ent:Spawn()
					 ent:Activate()	
				 end
			end
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
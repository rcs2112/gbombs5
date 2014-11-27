AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "gbombs_5/explosions/light_bomb/small_explosion_1.wav"
ExploSnds[2]                         =  "gbombs_5/explosions/light_bomb/small_explosion_2.wav"
ExploSnds[3]                         =  "gbombs_5/explosions/light_bomb/small_explosion_3.wav"
ExploSnds[4]                         =  "gbombs_5/explosions/light_bomb/small_explosion_4.wav"



ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Breaching Charge"
ENT.Author			                 =  "Rogue"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Light Bombs"

ENT.Model                            =  "models/weapons/w_c4.mdl"                      
ENT.Effect                           =  "high_explosive_air"                  
ENT.EffectAir                        =  "high_explosive_air"                   
ENT.EffectWater                      =  "water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/ex_1.wav"
 
ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  true

ENT.ExplosionRadius                  =  50
ENT.SpecialRadius                    =  50
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  2555                                
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  300
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  52
ENT.ArmDelay                         =  1   
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

ENT.Shocktime                        =  3
ENT.DEFAULT_PHYSFORCE                = 9955
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 9000
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 9000 
ENT.Decal                            = "scorch_small"

if SERVER then
	function ENT:Initialize()
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
		
		 self:EmitSound("gbombs_5/explosions/light_bomb/c2_timer.wav", self:GetPos(), 10, 100,1)
		
		 local physo = self:GetPhysicsObject()
		 physo:Wake()	
		 timer.Simple(4, function()
			 if !self:IsValid() then return end 
			 self.Exploding = true
			 local pos = self:GetPos()
			 for k, v in pairs(ents.FindInSphere(self:GetPos(),5)) do
				if v:GetClass() == "prop_door_rotating" then
					local ent = ents.Create("prop_physics")
					local old_ent_constrains = constraint.GetAllConstrainedEntities( v )
					local old_angle = v:GetAngles( )
					ent:SetPos( v:LocalToWorld(self:OBBCenter()) ) 	
					ent:SetModel(v:GetModel())
					ent:SetSkin(v:GetSkin())
					ent:Spawn()
					ent:Activate()
					ent:Ignite(1,0)
					ent:SetAngles(old_angle)
					ent.pos = v:LocalToWorld(self:OBBCenter())
					ent.angles = old_angle
					v:Remove()
					timer.Simple(61, function()
						if !ent:IsValid() then return end
						ent:Remove()
					end)
					
				end
			 end
			 local ent = ents.Create("gb5_shockwave_ent")
			 ent:SetPos( pos ) 
			 ent:Spawn()
			 ent:Activate()
			 ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
			 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
			 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
			 ent:SetVar("GBOWNER", self.GBOWNER)
			 ent:SetVar("MAX_RANGE",self.ExplosionRadius)
			 ent:SetVar("SHOCKWAVE_INCREMENT",10)
			 ent:SetVar("DELAY",0.01)
			 ent.trace=self.TraceLength
		     ent.decal=self.Decal
			 
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
			 ent:SetVar("SOUND", table.Random(ExploSnds))
			 ent:SetVar("Shocktime", self.Shocktime)
			
			 self:StopParticles()

			 local pos = self:GetPos()
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
				 else 
					 ParticleEffect(self.EffectAir,self:GetPos(),Angle(0,0,0),nil) 
				 end
			 end
		 self:Remove()
		 end)
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

function ENT:Think()
	if SERVER then
		if !self:IsValid() then return end
		for k, v in pairs(ents.FindInSphere(self:GetPos(),5)) do
			local phys = v:GetPhysicsObject()
			if v:GetClass() == "prop_door_rotating" or v:GetClass() == "func_door" or phys:IsValid() then
				constraint.Weld( self, v, 0, 0, 5000, true, false )
			end
		end
		self:NextThink(CurTime() + 0.1)
		return true
	end
end
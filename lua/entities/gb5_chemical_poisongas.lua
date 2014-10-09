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

ENT.PrintName		                 =  "Poison Gas"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Chemical"

ENT.Model                            =  "models/bomb_tiny/bomb_tiny.mdl"                      
ENT.Effect                           =  "poison_gas_large_ground"                  
ENT.EffectAir                        =  "poison_gas_large_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/chemical/gasleak_long.wav"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  12
ENT.PhysForce                        =  0
ENT.ExplosionRadius                  =  125
ENT.SpecialRadius                    =  66
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  50
ENT.ArmDelay                         =  1
ENT.Timer                            =  0

ENT.Shocktime                        = 0
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

if SERVER then
	function ENT:Explode()
		local ent = ents.Create("gb5_chemical_poisongas_b")
		local pos = self:GetPos()
		ent:SetPos( pos )
		ent:Spawn()
		ent:Activate()
		ent:SetVar("GBOWNER",self.GBOWNER)
		ent.RadRadius = 1000
		ent.Burst = 30
		
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
				ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
			end
		end
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
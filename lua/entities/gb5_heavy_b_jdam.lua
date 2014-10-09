AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "gbombs_5/explosions/heavy_bomb/explosion_big_2.wav"
ExploSnds[2]                         =  "gbombs_5/explosions/heavy_bomb/explosion_big_5.wav"
ExploSnds[2]                         =  "gbombs_5/explosions/light_bomb/mine_explosion.wav"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Jdam - 1150lb"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Heavy Bombs"

ENT.Model                            =  "models/military2/bomb/bomb_jdam.mdl"                      
ENT.Effect                           =  "jdam_explosion_ground"                  
ENT.EffectAir                        =  "jdam_explosion_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/heavy_bomb/ex2.wav"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  99
ENT.PhysForce                        =  2600
ENT.ExplosionRadius                  =  1600
ENT.SpecialRadius                    =  575
ENT.MaxIgnitionTime                  =  0 
ENT.Life                             =  20                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  350
ENT.Mass                             =  500
ENT.ArmDelay                         =  2   
ENT.Timer                            =  0

ENT.Shocktime                        = 4
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

ENT.Decal                            = "scorch_big"
function ENT:ExploSound(pos)
     if not self.Exploded then return end
	 if self.UseRandomSounds then
         sound.Play(table.Random(ExploSnds), pos, 160, 100,1)
     else
	     sound.Play(self.ExplosionSound, pos, 160, 100,1)
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

function ENT:Explode()
     if !self.Exploded then return end
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
	 ent.trace=self.TraceLength
	 ent.decal=self.Decal
	
	 local ent = ents.Create("gb5_shockwave_sound_lowsh")
	 ent:SetPos( pos ) 
	 ent:Spawn()
	 ent:Activate()
	 ent:SetVar("GBOWNER", self.GBOWNER)
	 ent:SetVar("MAX_RANGE",50000)
	 ent:SetVar("SHOCKWAVE_INCREMENT",100)
	 ent:SetVar("DELAY",0.01)
	 ent:SetVar("SOUND", table.Random(ExploSnds))
	 ent:SetVar("Shocktime", self.Shocktime)
	 
	 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius)) do
	     if v:IsValid() && !v:IsNPC() then
			 local i = 0
		     while i < v:GetPhysicsObjectCount() do
			 phys = v:GetPhysicsObjectNum(i)
			 i = i + 1
			 end
		 end
	 end
	 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius/2)) do
		 if self.ShouldIgnite then
			 if v:IsOnFire() then
				 v:Extinguish()
			 end
			 v:Ignite(math.Rand(self.MaxIgnitionTime-2,self.MaxIgnitionTime),5)
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
		 tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		 tracedata.filter   = self.Entity
				
		 local trace = util.TraceLine(tracedata)
	     
	     
		 if trace.HitWorld then
			 local ang = self:GetAngles()
			 ParticleEffect(self.Effect,pos,Angle(0,ang.y-270,0),nil) 
		 else 
			 local ang = self:GetAngles()
			 ParticleEffect(self.EffectAir,pos,Angle(0,ang.y-270,0),nil) 
		 end
     end
	 if self.IsNBC then
	     local nbc = ents.Create(self.NBCEntity)
		 nbc:SetVar("GBOWNER",self.GBOWNER)
		 nbc:SetPos(self:GetPos())
		 nbc:Spawn()
		 nbc:Activate()
	 end
     self:Remove()
end
AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "LEM - Cluster Mine" 
ENT.Author			                 =  "Rogue"
ENT.Contact			                 =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Mines"

ENT.Model                            =  "models/thedoctor/mines/clustermine_1.mdl"         
ENT.Effect                           =  "50lb_main"
ENT.EffectAir                        =  "50lb_air" 
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/mine_explosion.wav"         
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"  

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false         
ENT.ShouldExplodeOnImpact            =  true         
ENT.Flamable                         =  false         
ENT.UseRandomSounds                  =  false         
ENT.UseRandomModels                  =  false         
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  450            
ENT.PhysForce                        =  400             
ENT.ExplosionRadius                  =  200             
ENT.SpecialRadius                    =  200             
ENT.MaxIgnitionTime                  =  0             
ENT.Life                             =  15            
ENT.MaxDelay                         =  2            
ENT.TraceLength                      =  200        
ENT.ImpactSpeed                      =  900           
ENT.Mass                             =  30     
ENT.ArmDelay                         =  1        
ENT.Timer                            =  0

ENT.PushWeight                       =  5    --If something heavier or equal touches us - we explode.

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 if(self.Life <= 0) then return end
	 if(GetConVar("gb5_fragility"):GetInt() >= 1) then
	     if(data.Speed > self.ImpactSpeed) then
	 	     if(!self.Armed and !self.Arming) then
		         self:EmitSound(self.ActivationSound )
	             self:Arm()
	         end
		 end
	 end
	 if(!self.Armed) then return end
     if self.ShouldExplodeOnImpact then
	     local pusher = data.HitEntity
		 if (pusher:IsWorld() == true) then return end
		 local phys = pusher:GetPhysicsObject()
		 local pweight = phys:GetMass()
	     if (pweight >= self.PushWeight ) then         
			     self.Exploded = true
			     self:Explode()
		 end
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
	 ent:SetVar("DEFAULT_PHYSFORCE", 5)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 25)
	 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 25)
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

	 for i=0, (4-1) do
		 local ent1 = ents.Create("gb5_m_clustermine_bomblet") 
		 local phys = ent1:GetPhysicsObject()
		 ent1:SetPos( self:GetPos() ) 
		 ent1:Spawn()
		 ent1:Activate()
		 ent1:SetVar("GBOWNER", self.GBOWNER)
		 ent1:Ignite(1,0)
		 local bphys = ent1:GetPhysicsObject()
		 local phys = self:GetPhysicsObject()
		  if bphys:IsValid() and phys:IsValid() then
			 bphys:ApplyForceCenter(VectorRand() * bphys:GetMass() * 155)
			 bphys:AddVelocity(phys:GetVelocity()/2)
		 end
	 end

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
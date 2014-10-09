AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced_nuke" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Antimatter Canister"
ENT.Author			                 =  "natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Nuclear"

ENT.Model                            =  "models/thedoctor/antimatter_canister.mdl"                      
ENT.Effect                           =  "photon_torpedo"                  
ENT.EffectAir                        =  "photon_torpedo"                   
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
ENT.PhysForce                        =  6500
ENT.ExplosionRadius                  =  9000
ENT.SpecialRadius                    =  2500
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  100
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  150
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

function ENT:Arm()
     if(!self:IsValid()) then return end
	 if(self.Exploded) then return end
	 if(self.Armed) then return end
	 self.Arming = true
	 self.Used = true
	 timer.Simple(self.ArmDelay, function()
	     if !self:IsValid() then return end 
	     self.Armed = true
		 self.Arming = false
		 self:EmitSound(self.ArmSound)
		 self:StopParticles()
		 ParticleEffectAttach("flash_antimatter_warning",PATTACH_POINT_FOLLOW,self,0 ) 
		 if(self.Timed) then
	         timer.Simple(self.Timer, function()
	             if !self:IsValid() then return end 
				 timer.Simple(math.Rand(0,self.MaxDelay),function()
			         if !self:IsValid() then return end 
			         self.Exploded = true
			         self:Explode()
				 end)
	         end)
	     end
	 end)
end	 
function ENT:Explode()
	if !self.Exploded then return end
	if self.Exploding then return end
	local pos = self:LocalToWorld(self:OBBCenter())
	self:SetMoveType( MOVETYPE_NONE )
	self:SetMaterial("phoenix_storms/glass")
	self:SetModel("models/hunter/plates/plate.mdl")
	ParticleEffect("antimatter_main_burst",pos,Angle(0,0,0),nil)	
	self.Exploding = true
	timer.Simple(0.2, function()
		if !self:IsValid() then return end
		local ent = ents.Create("gb5_shockwave_sound_lowsh")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",500000)
		ent:SetVar("SHOCKWAVE_INCREMENT",20000)
		ent:SetVar("DELAY",0.01)
		ent:SetVar("Shocktime",12)
		ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/antimatter.wav")
		
		local ent = ents.Create("gb5_shockwave_ent_instant")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("DEFAULT_PHYSFORCE", 2550)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 1250)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 2555)
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",11000)
		ent:SetVar("Burst",2)
	    ent:SetVar("DELAY",0.5)
	end)
	timer.Simple(8, function()	
		if !self:IsValid() then return end
		local ent = ents.Create("gb5_shockwave_ent_instant")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("DEFAULT_PHYSFORCE", 2550)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 1205)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 2555)
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",11000)
		ent:SetVar("Burst",2)
	    ent:SetVar("DELAY",0.5)
	end)
	timer.Simple(20, function()	
		if !self:IsValid() then return end
		local ent = ents.Create("gb5_shockwave_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("DEFAULT_PHYSFORCE", -255)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", -655)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", -2550)
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",11000)
		ent:SetVar("SHOCKWAVE_INCREMENT",500)
		ent:SetVar("DELAY",0.1)
	end)
	timer.Simple(23, function()	
		if !self:IsValid() then return end
		local ent = ents.Create("gb5_shockwave_ent")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetVar("DEFAULT_PHYSFORCE", 255)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 655)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 2550)
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",11000)
		ent:SetVar("SHOCKWAVE_INCREMENT",1000)
		ent:SetVar("DELAY",0.1)
		self:Remove()
	end)
	
 
end


function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 26 ) 
     ent:Spawn()
     ent:Activate()
     ParticleEffectAttach("anti_glow",PATTACH_POINT_FOLLOW,ent,0 ) 
	 ent:EmitSound("gbombs_5/explosions/nuclear/antimatter_flicker.wav",50,100)
     return ent
end
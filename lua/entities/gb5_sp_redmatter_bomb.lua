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

ENT.PrintName		                 =  "Red-Matter Bomb"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Specials"

ENT.Model                            =  "models/thedoctor/redmatter.mdl"                      
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
  	 timer.Simple(0.2, function()
		 
	     if !self:IsValid() then return end 
		 self:SetNoDraw(true)
		 
		 local ent = ents.Create("gb5_sp_space_rupture")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("GBOWNER", self.GBOWNER)
		 ent.GBOWNER = self.GBOWNER
		 ent.SOUND = "gbombs_5/explosions/special/redmatter_explo.mp3"
		 ent.ShockTime=40
		 ent.StepIncrement=65
		 ent.Target_Range=1000
		 
		
		 
		 self:SetModel("models/gibs/scanner_gib02.mdl")
		 self.Exploding = true
		 for k, v in pairs(ents.FindInSphere(pos,self.SpecialRadius)) do
			 if v:IsValid() then
				 if v:IsValid() and v:GetPhysicsObject():IsValid() and !v:IsPlayer() then
					 constraint.RemoveAll(v)
					 local physo = v:GetPhysicsObject()
				 	 physo:EnableMotion(true)
				 end
			 end
         end
		 self:Remove()
     end)
	 
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
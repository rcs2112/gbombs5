AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  ""
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
	 self:SetNoDraw(true)
	 self.EventHorizon=0
	 self.FILTER={}
	 self.Max_Range=0
	 ParticleEffectAttach("redmatter_main",PATTACH_ABSORIGIN_FOLLOW,self,0 ) 
	 
	  if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

function ENT:Think(ply)		
	 if (CLIENT) then
		if LocalPlayer():GetNWBool("waiting", false)==false then
			if LocalPlayer():GetNWBool("ran_pitch", nil)==true then
				if !(LocalPlayer():GetNWInt("maxsound_dist", nil)==0) then -- realistic dist sound volume
					local dist = (self:GetPos() - LocalPlayer():GetPos()):Length()
					local relation = math.Clamp(( LocalPlayer():GetNWInt("maxsound_dist", nil) - dist) / LocalPlayer():GetNWInt("maxsound_dist", nil), 0, 1)
					print(relation)
					LocalPlayer():EmitSound(LocalPlayer():GetNWString("sound"), relation*100, math.random(80,120))
				else
					LocalPlayer():EmitSound(LocalPlayer():GetNWString("sound"), 100, math.random(80,120))
				end
			else
				if !(LocalPlayer():GetNWInt("maxsound_dist", nil)==0) then -- realistic dist sound volume
					local dist = (self:GetPos() - LocalPlayer():GetPos()):Length()
					local relation = math.Clamp(( LocalPlayer():GetNWInt("maxsound_dist", nil) - dist) / LocalPlayer():GetNWInt("maxsound_dist", nil), 0, 1)
					print(relation)
					LocalPlayer():EmitSound(LocalPlayer():GetNWString("sound"), relation*100, 100)
				else
					LocalPlayer():EmitSound(LocalPlayer():GetNWString("sound"), 100, 100)
				end
			end
			
			LocalPlayer():SetNWBool("waiting", true)
			LocalPlayer():SetNWInt("maxsound_dist", nil)
			LocalPlayer():SetNWBool("ran_pitch", false)
		end
	 end
     if (SERVER) then
     if !self:IsValid() then return end
	 local pos = self:GetPos()
	 self.Max_Range = self.Max_Range + self.StepIncrement
	 
	 self.EventHorizon=self.EventHorizon+5
	 for k, v in pairs(ents.FindInSphere(pos,60000)) do
		 if v:IsPlayer() then
			 if !(table.HasValue(self.FILTER,v)) then
				v:SetNWBool("waiting", true)
				v:SetNWBool("ran_pitch", false)
				v:SetNWInt("maxsound_dist", nil)
				v:SetNWBool("waiting", false)
				v:SetNWBool("ran_pitch", self.RandomPitch)
				v:SetNWInt("maxsound_dist", self.Maxsounddist)
				v:SetNWString("sound", self.SOUND)
				
				
				if self:GetVar("Shocktime") == nil then
					self.ShockTime = 1
				else
					self.ShockTime = self:GetVar("Shocktime")
				end
				if GetConVar("gb5_sound_shake"):GetInt()== 1 then
					util.ScreenShake( v:GetPos(), 5555, 555, self.ShockTime, 500 )
				end
				table.insert(self.FILTER, v)
				
			 end
		 end
	 end
	 for k, v in pairs(ents.FindInSphere(pos,self.EventHorizon)) do
		if v:IsValid() && v:GetPhysicsObject():IsValid() then
		end
	 end
	 for k, v in pairs(ents.FindInSphere(pos,self.Max_Range)) do
		 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 local dmg = DamageInfo()
					 if !(self.damage==nil) then
						dmg:SetDamage(math.random(self.damage[0],self.damage[1]))
					 else
						dmg:SetDamage(math.random(0,1))
					 end
			         dmg:SetDamageType(DMG_RADIATION)
			         if self.GBOWNER == nil then
						self.GBOWNER = table.Random(player.GetAll())
					 end
					 if !self.GBOWNER:IsValid() then
						self.GBOWNER = table.Random(player.GetAll())
					 end
				 phys = v:GetPhysicsObjectNum(i)
				 if (phys:IsValid()) then
					 local mass = phys:GetMass()
					 local F_ang = self.DEFAULT_PHYSFORCE
					 local dist = (pos - v:GetPos()):Length()
					 local relation = math.Clamp((self.Max_Range - dist) / self.Max_Range, 0, 1)
					 local F_dir = (v:GetPos() - pos):GetNormal() * self.DEFAULT_PHYSFORCE 
					 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
					 phys:AddVelocity(F_dir)
					 if(GetConVar("gb5_shockwave_unfreeze"):GetInt() >= 1) then
						 phys:Wake()
						 phys:EnableMotion(true)
						 constraint.RemoveAll(v)
					 end
				 end
				 if (v:IsPlayer()) then
					
					 v:SetMoveType( MOVETYPE_WALK )
				     v:TakeDamageInfo(dmg)
					 local mass = phys:GetMass()
					 local F_ang = self.DEFAULT_PHYSFORCE_PLYAIR
					 local dist = (pos - v:GetPos()):Length()
					 local relation = math.Clamp((self.Max_Range - dist) / self.Max_Range, 0, 1)
					 local F_dir = (v:GetPos() - pos):GetNormal() * self.DEFAULT_PHYSFORCE_PLYAIR
					 v:SetVelocity( F_dir )		
				 end

				 if (v:IsPlayer()) and v:IsOnGround() then
					 v:SetMoveType( MOVETYPE_WALK )
				     v:TakeDamageInfo(dmg)
					 local mass = phys:GetMass()
					 local F_ang = self.DEFAULT_PHYSFORCE_PLYGROUND
					 local dist = (pos - v:GetPos()):Length()
					 local relation = math.Clamp((self.Max_Range - dist) / self.Max_Range, 0, 1)
					 local F_dir = (v:GetPos() - pos):GetNormal() * self.DEFAULT_PHYSFORCE_PLYGROUND	 
					 v:SetVelocity( F_dir )		
				 end
				 if (v:IsNPC()) then
					 v:TakeDamageInfo(dmg)
				 end
			 i = i + 1
			 end
		 end
 	 end

	 if self.Max_Range>=self.Target_Range then
	    self:StopParticles()
		self:Remove()
	 end
	 self:NextThink(CurTime() + 0.01)
	 return true
	 end
end

function ENT:OnRemove()	
	
	self:StopParticles()
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
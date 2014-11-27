AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )


ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Grigors Holy Bible"
ENT.Author			                 =  "Rogue"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Misc"

ENT.Model                            =  "models/props_lab/binderblue.mdl"                      
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  ""
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false


function ENT:Explode()
end

function ENT:Initialize()
	if (SERVER) then
		 self:LoadModel()
		 self:PhysicsInit( SOLID_VPHYSICS )
		 self:SetSolid( SOLID_VPHYSICS )
		 self:SetMoveType( MOVETYPE_VPHYSICS )
		 self:SetUseType( ONOFF_USE ) 
		 local phys = self:GetPhysicsObject()
		 local skincount = self:SkinCount()
		 if (phys:IsValid()) then
			 phys:SetMass(25)
			 phys:Wake()
		 end
		 self:EmitSound("gbombs_5/explosions/special/zomb.wav", 70, 100)
	end
end

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
     self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
     ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 26 ) 
     ent:Spawn()
     ent:Activate()
     return ent
end

function ENT:Think()
	if SERVER then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 500)) do
			if v:GetClass()=="gb5_misc_babybomb" then
				local phys = v:GetPhysicsObject()
				local mass = phys:GetMass()
				local F_ang = 550
				local dist = (v:GetPos() - v:GetPos()):Length()

				local relation = math.Clamp((500 - dist) / 500, 0, 1)
				local F_dir = (self:GetPos() - v:GetPos()):GetNormal() * -50
				phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
				phys:AddVelocity(F_dir)
			end
		end
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 200)) do
			if v:GetClass()=="gb5_misc_babybomb" then
				if v.exorcised==nil or v.exorcised==false then
					local dmg = DamageInfo()
					dmg:SetDamage(500000000)
					dmg:SetDamageType(DMG_DISSOLVE)
					dmg:SetAttacker(self.GBOWNER)
					v:TakeDamageInfo(dmg)
					v.exorcised=true
					v:EmitSound("gbombs_5/explosions/special/zomb.wav", 70, 100)
				end
			end
		end
	end
end
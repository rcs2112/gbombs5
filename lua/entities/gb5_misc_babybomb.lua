AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )


ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Unholy Baby Bomb"
ENT.Author			                 =  "Rogue"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Misc"

ENT.Model                            =  "models/props_c17/doll01.mdl"                      
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
			 phys:AddVelocity(Vector(math.random(1,100),math.random(1,100),math.random(1,100)))
		 end
		 self:EmitSound("ambient/creatures/teddy.wav", 70, 100)
		 
		 timer.Simple(math.random(1,5), function()
			if self:IsValid() then
				self:EmitSound("gbombs_5/explosions/special/zomb.wav", 70, 30)
				sound.Play("ambient/creatures/town_child_scream1.wav", self:GetPos(), 50, 50)
				self:Remove()
			end
		 end)
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
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 5500)) do
			if v:IsPlayer() && v:Alive() then
				local phys = self:GetPhysicsObject()
				local mass = phys:GetMass()
				local F_ang = -550
				local dist = (v:GetPos() - v:GetPos()):Length()

				local relation = math.Clamp((500 - dist) / 500, 0, 1)
				local F_dir = (self:GetPos() - v:GetPos()):GetNormal() * -2550
				phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
				phys:AddVelocity(F_dir)
			end
		end
		for k, v in pairs(ents.FindInSphere(self:GetPos(),60)) do
			if v:IsPlayer() && v:Alive() && (self.alloweat==false or self.alloweat==nil) then
			
				local ent = ents.Create( self:GetClass() )
				ent:SetPhysicsAttacker(ply)
				ent:SetPos( self:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				local ent = ents.Create( self:GetClass() )
				ent:SetPhysicsAttacker(ply)
				ent:SetPos( self:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				 
				self.alloweat=true
				self.eat=true
				sound.Play("ambient/creatures/town_child_scream1.wav", v:GetPos(),70, 100)
				sound.Play("ambient/voices/player/damage2.wav.wav", v:GetPos(),90, 100)
				v:SetModel("models/Humans/Charple03.mdl")
				local pos = v:GetPos()
				local tracedata    = {}
				tracedata.start    = pos
				tracedata.endpos   = tracedata.start - Vector(0, 0, 100)
				tracedata.filter   = self.Entity
				local trace = util.TraceLine(tracedata)					
				util.Decal( "Blood", tracedata.start, tracedata.endpos )
				ParticleEffectAttach("blood_explosion",PATTACH_POINT_FOLLOW,v,v:LookupAttachment("mouth") )
				v:EmitSound("gbombs_5/arm/pie_eat.mp3", 80, 100)
				
				local ent = ents.Create("prop_physics")
				ent:SetModel("models/Gibs/HGIBS.mdl")
				ent:SetPos( v:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				v:Kill()
				timer.Simple(10, function()
					if ent:IsValid() then 
						ent:Remove()
					end
				end)
			end
		end
	end
end

function ENT:OnRemove()
	if SERVER then
		local ent = ents.Create( "gb5_misc_babybomb" )
		ent:SetPhysicsAttacker(self.GBOWNER)
		ent:SetPos( self:GetPos() ) 
		ent:Spawn()
		ent:Activate()
		

	end
end
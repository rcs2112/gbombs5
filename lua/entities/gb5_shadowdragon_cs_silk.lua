AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )


ENT.Spawnable		            	 =  false       
ENT.AdminSpawnable		             =  false

ENT.PrintName		                 =  "Shadow Dragons Coarse Silk"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  ""

ENT.Model                            =  "models/thedoctor/pellet.mdl"           
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""   
ENT.EffectWater                      =  "" 
ENT.ExplosionSound                   =  ""                   
ENT.ParticleTrail                    =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false      
ENT.ShouldExplodeOnImpact            =  false         
ENT.Flamable                         =  false        
ENT.UseRandomSounds                  =  false       
ENT.UseRandomModels                  =  false

ENT.ExplosionDamage                  =  1          
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  3           
ENT.SpecialRadius                    =  4            
ENT.MaxIgnitionTime                  =  1           
ENT.Life                             =  2555         
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  0        
ENT.ImpactSpeed                      =  2555         
ENT.Mass                             =  25

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.


function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
     ent:SetPos( tr.HitPos + tr.HitNormal * 25 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end



function ENT:Initialize()
	if (SERVER) then
		 self:LoadModel()
		 self:PhysicsInit( SOLID_VPHYSICS )
		 self:SetSolid( SOLID_VPHYSICS )
		 self:SetMoveType( MOVETYPE_VPHYSICS )
		 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
		 local phys = self:GetPhysicsObject()
		 local skincount = self:SkinCount()
		 if (phys:IsValid()) then
			 phys:SetMass(self.Mass)
			 phys:Wake()
			 
			 
		 end
		 if (skincount > 0) then
			 self:SetSkin(math.random(0,skincount))
		 end
		 timer.Simple(math.random(2,4)/10, function()
			if !self:IsValid() then return end
			self:Remove()
		 end)
		 self.Exploded = false
		local phys = self:GetPhysicsObject()
		if math.random(1,2)==1 then
			phys:AddVelocity(Vector(math.random(155,-155),math.random(155,-155),math.random(155,-100)))
			local trail = util.SpriteTrail(self, 0, Color(255,255,255), false, math.random(1,15), 1, 0.25, 1/(2+0)*0.5, "effects/beam_generic01.vmt")
		else
			phys:AddVelocity(Vector(math.random(855,-855),math.random(855,-855),math.random(855,-500)))
			local trail = util.SpriteTrail(self, 0, Color(0,0,0), false, math.random(1,15), 1, 0.25, 1/(2+0)*0.5, "effects/beam_generic01.vmt")
			local trail = util.SpriteTrail(self, 0, Color(0,0,math.random(50,150)), false, math.random(1,3), 1, 0.25, 1/(1+0)*0.5, "effects/beam_generic01.vmt")
		end
		self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		self:SetNoDraw(true)
	end
end

function ENT:PhysicsCollide( data, physobj )
     if(self.Exploded) then return end
     if(!self:IsValid()) then return end
	 self:Remove()
end

function ENT:Think() 
	if SERVER then
		if !self:IsValid() then return end
		local phys = self:GetPhysicsObject()
		local hitpos = self.GBOWNER:GetEyeTrace().HitPos
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 50)) do
			if v!=self.GBOWNER && (v:IsNPC() or v:IsPlayer()) then
				local dmg = DamageInfo()
				dmg:SetDamage(math.random(1,5))
				dmg:SetDamageType(DMG_BLAST)
				dmg:SetAttacker(self.GBOWNER)
				v:TakeDamageInfo(dmg)
			end
		end
		if self:GetPos():Distance(hitpos) < 500 then
			local phys = self:GetPhysicsObject()
			
			local F_dir = (hitpos-self:GetPos()):GetNormal() * -100550
		else
			local phys = self:GetPhysicsObject()
			local F_dir = (self:GetPos() - hitpos):GetNormal() * -8000
			phys:AddVelocity(F_dir)
		end
		self:NextThink(CurTime() + 0.01)
		return true
	end
end
		
		
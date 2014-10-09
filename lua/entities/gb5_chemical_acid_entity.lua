AddCSLuaFile()

DEFINE_BASECLASS( "gb5_nuclear_fission_rad_base" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "acid"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

function ENT:Initialize()
	 if (SERVER) then
		 self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		 self:SetSolid( SOLID_NONE )
		 self:SetMoveType( MOVETYPE_NONE )
		 self:SetUseType( ONOFF_USE ) 	
	     self:SetNoDraw(true)
		 self.Bursts=0
	 end
end


function ENT:Think()	
	if (SERVER) then
	if !self:IsValid() then return end
	if !self.acidowner:IsValid() then -- doesnt fucking work
		self:Remove()
	end
	if !self.acidowner:IsValid() then return end
	pos = string.Explode( " ", tostring(self.acidowner:GetPos()) )
	self:SetPos(Vector(pos[1],pos[2],pos[3]))
	
	local dmg = DamageInfo()
	dmg:SetDamage(math.random(1,3))
	dmg:SetDamageType(DMG_BULLET)
	if self.GBOWNER == nil then
		self.GBOWNER = table.Random(player.GetAll())
	end
	if !self.GBOWNER:IsValid() then
		self.GBOWNER = table.Random(player.GetAll())
	end
	dmg:SetAttacker(self.GBOWNER)
	self.acidowner:TakeDamageInfo(dmg)
	self.acidowner.acid=self.acidowner.acid+2
	self.Bursts = self.Bursts + 1

	if self.Bursts>25 then
		self:Remove()
	end
	
	if self.acidowner.acid>80 then
		self.acidowner:SetModel("models/Humans/corpse1.mdl")
		local dmg = DamageInfo()
		dmg:SetDamage(500000000)
		dmg:SetDamageType(DMG_BULLET)
		dmg:SetAttacker(self.GBOWNER)
		self.acidowner:TakeDamageInfo(dmg)
	end
	if self.acidowner:IsNPC() then
		if !self.acidowner:IsValid() then
			self.acidowner:StopParticles()
			self:Remove()
		end
	elseif self.acidowner:IsPlayer() then
		if !self.acidowner:Alive() then
			self.acidowner.acid=0
			self.acidowner:StopParticles()
			self:Remove()
		end
	end
	
	self:NextThink(CurTime() + 0.2)
	return true
	end
end


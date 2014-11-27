AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      
          
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 
     end
end

function ENT:Think()
	if (CLIENT) then
		for k, v in pairs(ents.FindInSphere(self:GetPos(), 500)) do
			if v==LocalPlayer() then
				LocalPlayer():GetActiveWeapon():SetPlaybackRate( 0.5 )
			end
		end
	end
	if (SERVER) then
	if !self:IsValid() then return end
	local pos = self:GetPos()
	self.TotalList={}
	for k, v in pairs(ents.FindInSphere(self:GetPos(), 500)) do
		phys = v:GetPhysicsObject()
		if phys:IsValid() then
			local velocity = v:GetVelocity()
	
			if v:IsPlayer() then
				v:Freeze(true)
				v.frozen=self
				v:SetVelocity(v:GetVelocity()*-1)
				
			else
				velocity = -1*(velocity*0.1)
				phys:AddVelocity(velocity)
			end
			
		end
	end


	self.Bursts = self.Bursts + 0.01
	if (self.Bursts >= 10) then
		self:Remove()
	end
	self:NextThink(CurTime() + 0.01)
	return true
	end
end

function ENT:OnRemove()
	for k, v in pairs(player.GetAll()) do
		if v.frozen==self then
			v:Freeze(false)
		end
	end
end

function ENT:Draw()
     return true
end
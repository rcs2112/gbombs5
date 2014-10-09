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
		 self.GBOWNER = self:GetVar("GBOWNER")
     end
end

function ENT:Think()
	if (SERVER) then
	if !self:IsValid() then return end
	if self.radowner:IsValid() then 
		self.pos = string.Explode( " ", tostring(self.radowner:GetPos()) )
		self:SetPos(Vector(self.pos[1],self.pos[2],self.pos[3]))
		local pos = self:GetPos()
		self.radowner:Fire("TurnOff", 0.1, 0)
	else
		self:Remove()
	end
	self:NextThink(CurTime() + 0.01)
	return true
	end
end

function ENT:Draw()
     return true
end
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
		 self:SetNoDraw(true)
     end
end

function ENT:Think()
	if (SERVER) then
	if !self:IsValid() then return end
	local pos = self:GetPos()

	for k, v in pairs(ents.FindInSphere(self:GetPos(), 80000)) do
		if v:IsPlayer() then
			if v.magicpower==nil then
				v.magicpower=500
			end

			if v.magicpower<1000 then
				if math.random(1,1000)==1 then
					v.magicpower=v.magicpower+1
				end
			end
		end
	end
	self:NextThink(CurTime() + 0.01)
	return true
	end
end

function ENT:Draw()
     return true
end

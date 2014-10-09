AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      
         
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
		 self.spawns = 0
		 self.extra=26
		 self:SetNoDraw(true)
		 self.Count=0

     end
end

function ENT:Think()
	if (SERVER) then
	if !self:IsValid() then return end
	local pl = self.GBOWNER
	self.spawns = self.spawns+1
	self.Count=self.Count+0.01
	local ent = ents.Create("gb5_shadowdragon_cs_silk")
	local pos = self:GetPos()
	ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	local offset = self:GetPos() + 55 * self:GetForward() 
	offset = offset + 50 * self:GetUp()
	ent:SetPos( offset )
	ent:Spawn() 
	ent.Ignoreowner=true
	ent.Ignore=self.GBOWNER
	ent.GBOWNER = self.GBOWNER

	
	

	local traceRes=pl:GetEyeTrace()
	self:SetPos( pl:GetPos() ) 
	self:SetAngles(pl:EyeAngles())
	if self.Count>=10 then
		self:Remove()
	end

	
	self:NextThink(CurTime() + 0.01)
	return true
	end
end

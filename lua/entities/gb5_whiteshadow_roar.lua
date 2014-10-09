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
		 self.extra=39

     end
end
function ENT:SpawnMulti()
	local x = 1
	for i=0, (39-1) do
		x = x + 1
		local ent = ents.Create("gb5_shockwave_roar")
		local pos = self:GetPos()
		ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
		ent:SetPos(self:GetPos() + (90*x) * self:GetForward() )
		ent:Spawn() 
		ent:SetVar("DEFAULT_PHYSFORCE", 155)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 155)
		ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 55)
		ent:SetVar("MAX_RANGE", 400)
		ent:SetVar("SHOCKWAVE_INCREMENT",100)
		ent:SetVar("DELAY",0.01)
		ent.Ignoreowner=true
		ent.Ignore=self.GBOWNER
		ent.GBOWNER = self.GBOWNER
	end
end
function ENT:Think()
	if (SERVER) then
	if !self:IsValid() then return end
	self.spawns = self.spawns+1
	local ent = ents.Create("gb5_shockwave_roar")
	local pos = self:GetPos()
	ent:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	ent:SetPos(self:GetPos() + (90*self.spawns) * self:GetForward() )
	ent:Spawn() 
	ent:SetVar("DEFAULT_PHYSFORCE", 155)
	ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 155)
	ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 55)
	ent:SetVar("MAX_RANGE", 400)
	ent:SetVar("SHOCKWAVE_INCREMENT",100)
	ent:SetVar("DELAY",0.01)
	ent.Ignoreowner=true
	ent.Ignore=self.GBOWNER
	ent.GBOWNER = self.GBOWNER
	local pl = ent.GBOWNER
	local traceRes=pl:GetEyeTrace()
	self:SetPos( pl:GetPos() ) 
	self:SetAngles(pl:EyeAngles())
	if traceRes.HitWorld && self.spawns > 26 then
		if traceRes.HitPos:Distance(self:GetPos()) <= 3435 then
			ParticleEffect("whiteshadowdragon_roar_tracer_hit",traceRes.HitPos,Angle(0,0,0),nil)
		end
	end
	if self.spawns > 39 then 
		self:SpawnMulti()
		if self.extra>100 then
			self:Remove()
		end
		self.extra=self.extra+1
	end
	self:NextThink(CurTime() + 0.05)
	return true
	end
end

function ENT:Draw()
     return true
end
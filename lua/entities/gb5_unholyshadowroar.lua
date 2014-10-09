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

     end
end
function ENT:SpawnMulti()
	local x = 1
	for i=0, (60-1) do
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
		self.tracehitted=false
	end
end
function ENT:Think()
	if (SERVER) then
	if !self:IsValid() then return end
	self.spawns = self.spawns+2
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
	if traceRes.HitWorld && self.spawns > 60 then
		if (traceRes.HitPos:Distance(self:GetPos()) <= 5600) then
			ParticleEffect("unholyshadowdragon_roar_tracer_hit",traceRes.HitPos,Angle(0,0,0),nil)		
			local ent = ents.Create("gb5_shockwave_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent:SetVar("DEFAULT_PHYSFORCE", 500)
			ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", 155)
			ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", 155)
			ent:SetVar("GBOWNER", self.GBOWNER)
			ent:SetVar("MAX_RANGE",2800)
			ent:SetVar("SHOCKWAVE_INCREMENT",200)
			ent:SetVar("DELAY",0.01)
			ent.trace=self.TraceLength
			ent.decal=self.Decal

			local ent = ents.Create("gb5_shockwave_sound_lowsh")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent:SetVar("GBOWNER", self.GBOWNER)
			ent:SetVar("MAX_RANGE",50000)
			if GetConVar("gb5_sound_speed"):GetInt() == 0 then
				ent:SetVar("SHOCKWAVE_INCREMENT",200)
			elseif GetConVar("gb5_sound_speed"):GetInt()== 1 then
				ent:SetVar("SHOCKWAVE_INCREMENT",300)
			elseif GetConVar("gb5_sound_speed"):GetInt() == 2 then
				ent:SetVar("SHOCKWAVE_INCREMENT",400)
			elseif GetConVar("gb5_sound_speed"):GetInt() == -1 then
				ent:SetVar("SHOCKWAVE_INCREMENT",100)
			elseif GetConVar("gb5_sound_speed"):GetInt() == -2 then
				ent:SetVar("SHOCKWAVE_INCREMENT",50)
			else
				ent:SetVar("SHOCKWAVE_INCREMENT",200)
			end
			ent:SetVar("DELAY",0.01)
			ent:SetVar("SOUND", "gbombs_5/explosions/special/explosion_1.wav")
			ent:SetVar("Shocktime", 2)
			self:Remove()
		end
	end
	if self.spawns > 60 then 
		self:SpawnMulti()
		if self.extra>60 then
			self:Remove()
		end
		self.extra=self.extra+1
	end
	self:NextThink(CurTime() + 0.05)
	return true
	end
end

function ENT:Draw()
     return false
end
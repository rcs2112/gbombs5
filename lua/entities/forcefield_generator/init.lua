AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:TriggerInput(iname, value)
	 if (iname == "Range") then
	    if self.Range < 1 then
			self.Range = 1
			local phys = self:GetPhysicsObject()
			phys:SetMass( 1 )
		end
		if self.Range > 0 then
			self.Range = value
			local phys = self:GetPhysicsObject()
			phys:SetMass( self.Range/2)
		end
	 end
	 if (iname == "On") then
		if value == 1 then
		if self.Activated == 0 && self.Useable == 1 then
		self.Entity:EmitSound( "buttons/lever4.wav", 62, 100 )
		timer.Simple(0.32, function() self:EnableUse() end)
		self.Activated = 1
		self.Useable = 0
		return end
		end
		if value == 0 then
		if self.Activated == 1 && self.Useable == 1 then
		self.Entity:EmitSound( "buttons/lever5.wav", 72, 100 )
		timer.Simple(0.32, function() self:EnableUse() end)
		self.Activated = 0
		self.Useable = 0
		return end
		end
	 end
end 

function ENT:Think()
	if self.Activated != 1 then 
		for k, v in pairs(self.EntList) do
			if v:IsValid() then
				v.forcefielded=false
			end
			if !v:IsValid() then
				table.remove(self.EntList, k)	
			end
		end
		self:StopParticles()
		self.EntList={}
		self.alloweffect=true
		self:SetNWBool("on", false)
		
	end
	if (self.Activated==1) && (self.alloweffect==true) then 
		ParticleEffectAttach("forcefield_warp_idle",PATTACH_ABSORIGIN_FOLLOW,self,0) 
		self.alloweffect=false
		self:SetNWBool("on", true)
	end
	self:SetNWInt("field_range", self.Range)
	if self.Activated != 1 then return end
	self.TotalList={}
	if self.Range >= GetConVar("gb5_maxforcefield_range"):GetInt() then
		self.Range=GetConVar("gb5_maxforcefield_range"):GetInt()
	end
	
	for k, v in pairs(ents.FindInSphere(self:GetPos(),self.Range)) do
		local phys = v:GetPhysicsObject()
		if v:IsNPC() or v:IsPlayer() then
			table.insert(self.TotalList, v )
		end
		if !v:IsPlayer() or !v:IsNPC()then	 
			if v.Armed or v.Arming or v:GetClass() == "npc_grenade_frag" then
				 local mass = phys:GetMass()
				 local F_ang = 555000
				 local dist = (self:GetPos() - v:GetPos()):Length()
				 local relation = math.Clamp((self.Range- dist) / self.Range, 0, 1)
				 local F_dir = (v:GetPos() - self:GetPos()):GetNormal() * 550000
				 phys:Sleep()
				 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
				 phys:AddVelocity(F_dir)
				 ParticleEffectAttach("forcefield_warp_flash",PATTACH_ABSORIGIN_FOLLOW,v,0) 
				 sound.Play("ambient/energy/zap3.wav", v:GetPos(), 100, 100, 1)
			else 
				if !table.HasValue(self.TotalList,v) then
					table.insert(self.TotalList, v )
				end
			end				
		end
	end
	for k, v in pairs(self.TotalList) do
		if v:IsValid() && !table.HasValue(self.EntList,v) then
			table.insert(self.EntList, v )
			v.forcefielded=true
		end
		if !v:IsValid() then
			table.remove(self.EntList, k)	
		end
	end
	for k_, v_ in pairs(self.EntList) do
		if !table.HasValue(self.TotalList, v_) then
			table.remove(self.EntList, k_)
			v_.forcefielded=false
			
		end
	end		
	self:NextThink(CurTime() + 0.01)
	return true
end

function ENT:OnRemove()
	if SERVER then
		for k_, v_ in pairs(self.EntList) do
			v_.forcefielded=false	
		end		
	end
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/oildrum001.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then	
	phys:Wake()
	end
	self.Useable = 1
	self.Activated = 0
	self.Range = 1
	self.EntList={}
	self.EntCount=0
	self.alloweffect=true
	if !(WireAddon == nil) then 
		self.Inputs   = Wire_CreateInputs(self, { "Range", "On"}) 
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( "forcefield_generator" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:EnableUse()
self.Useable = 1
end

function ENT:Use( activator, caller )
	if self.Activated == 0 && self.Useable == 1 then
		self.Entity:EmitSound( "buttons/lever4.wav", 62, 100 )
		timer.Simple(0.32, function() self:EnableUse() end)
		self.Activated = 1
		self.Useable = 0
	return end
	if self.Activated == 1 && self.Useable == 1 then
		self.Entity:EmitSound( "buttons/lever5.wav", 72, 100 )
		timer.Simple(0.32, function() self:EnableUse() end)
		self.Activated = 0
		self.Useable = 0
	return end
end




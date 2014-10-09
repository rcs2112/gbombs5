AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

function ENT:TriggerInput(iname, value)
	 if (iname == "Range") then
	    if self.Range < 1 then
			self.Range = 1
		end
		if self.Range > 0 then
			self.Range = value
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
		self.EntCount=0
		self.EntList={}
		Wire_TriggerOutput(self, "Count", self.EntCount)	
		Wire_TriggerOutput(self, "Detected", 0)
	end
	if self.Activated != 1 then return end
	self.TotalList={}
	for k, v in pairs(ents.FindInSphere(self:GetPos(),self.Range)) do
		if !v:IsPlayer() or !v:IsNPC() then
			if v.Armed or v.Arming then
				if !table.HasValue(self.TotalList,v) then
					table.insert(self.TotalList, v )
				end
			end				
		end
	end
	for k, v in pairs(self.TotalList) do
		if v:IsValid() && !table.HasValue(self.EntList,v) then
			table.insert(self.EntList, v )
			self.EntCount = self.EntCount + 1
			Wire_TriggerOutput(self, "Count", self.EntCount)
		end
		if !v:IsValid() then
			table.remove(self.EntList, k)
			self.EntCount = self.EntCount - 1
			Wire_TriggerOutput(self, "Count", self.EntCount)		
		end
	end
	for k_, v_ in pairs(self.EntList) do
		if !table.HasValue(self.TotalList, v_) then
			table.remove(self.EntList, k)
			self.EntCount = self.EntCount - 1
			Wire_TriggerOutput(self, "Count", self.EntCount)
		end
	end		
	if self.EntCount>0 then
		Wire_TriggerOutput(self, "Detected", 1)	
	else 
		Wire_TriggerOutput(self, "Detected", 0)
    end
	self:NextThink(CurTime() + 0.5)
	return true
end

function ENT:Initialize()
	self.Entity:SetModel("models/props_c17/utilitypole03a.mdl")
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
	if !(WireAddon == nil) then 
		self.Inputs   = Wire_CreateInputs(self, { "Range", "On"}) 
		self.Outputs  = Wire_CreateOutputs(self, { "Detected", "Count"})
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( "missile_detector" )
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




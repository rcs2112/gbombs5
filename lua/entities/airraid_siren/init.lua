AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include('shared.lua')

sound.Add( {
	name = "airraid_siren",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 160,
	pitch = {100, 100},
	sound = "gbombs_5/sirens/airraid_siren_2.wav"
} )
function ENT:TriggerInput(iname, value)
	 if (iname == "On") then
		if value == 1 then
		if self.Activated == 0 && self.Useable == 1 then
		timer.Simple(0.42, function() self:Havok() end)
		self.Entity:EmitSound( "buttons/lever4.wav", 62, 100 )
		timer.Simple(0.32, function() self:EnableUse() end)
		self.Activated = 1
		self.Useable = 0
		return end
		end
		if value == 0 then
		if self.Activated == 1 && self.Useable == 1 then
		timer.Simple(0.42, function() self:EndHavok() end)
		self.Entity:EmitSound( "buttons/lever5.wav", 72, 100 )
		timer.Simple(0.32, function() self:EnableUse() end)
		self.Activated = 0
		self.Useable = 0
		return end
		end
	 end
end 


function ENT:Initialize()
	for var=1, 15, 1 do
	util.PrecacheSound("ambient/levels/prison/radio_random" .. var .. ".wav")
	end

	util.PrecacheSound("buttons/lever4.wav")
	util.PrecacheSound("buttons/lever5.wav")

	self.Entity:SetModel("models/props_lab/citizenradio.mdl")
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then	
	phys:Wake()
	end

	self.Useable = 1
	self.Activated = 0
	if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "On" }) end
end

function ENT:SpawnFunction( ply, tr )

if ( !tr.Hit ) then return end

local SpawnPos = tr.HitPos + tr.HitNormal * 16
local ent = ents.Create( "airraid_siren" )
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
timer.Simple(0.42, function() 
if !self:IsValid() then return end
self:Havok() end)
self.Entity:EmitSound( "buttons/lever4.wav", 62, 100 )
timer.Simple(0.32, function() if !self:IsValid() then return end
self:EnableUse() end)
self.Activated = 1
self.Useable = 0
return end

if self.Activated == 1 && self.Useable == 1 then
timer.Simple(0.42, function() 
if !self:IsValid() then return end
self:EndHavok() 
end)
self.Entity:EmitSound( "buttons/lever5.wav", 72, 100 )
timer.Simple(0.32, function() 
if !self:IsValid() then return end
self:EnableUse() end)
self.Activated = 0
self.Useable = 0
return end

end

function ENT:Think()
if self.Activated == 1 then
end
end

function ENT:Havok()
self:EmitSound("airraid_siren")

for k,ply in pairs(player.GetAll()) do
ply:ChatPrint( "Air-raid siren activated")
end

end

function ENT:EndHavok()

local squad = self:GetNetworkedString( 12 )

self.Entity:StopSound("airraid_siren")

for k,ply in pairs(player.GetAll()) do
ply:ChatPrint( "Air-raid siren deactivated")
end

end

function ENT:OnRemove()

local squad = self:GetNetworkedString( 12 )
self.Entity:StopSound("airraid_siren")
end
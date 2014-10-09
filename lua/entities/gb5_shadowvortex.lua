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
		 self.Plylist={}
		 self.EntList={}
		 sound.Play("ambience/_cache_/bin_32/shadow_vortex.wav", self:GetPos(), 75, 100, 1)
     end
end

function ENT:Think()
	if (CLIENT) then
		function Shadowvortex()
			local tab = {}
			tab[ "$pp_colour_addr" ] = 0 
			tab[ "$pp_colour_addg" ] = 0
			tab[ "$pp_colour_addb" ] = 0 
			tab[ "$pp_colour_brightness" ] = 0
			tab[ "$pp_colour_contrast" ] = 1-LocalPlayer():GetNWInt("contrast_shadow", 0)/1
			tab[ "$pp_colour_colour" ] = 1
			tab[ "$pp_colour_mulr" ] = 0
			tab[ "$pp_colour_mulg" ] = 0
			tab[ "$pp_colousr_mulb" ] = 0 
			DrawColorModify( tab )
		end
		hook.Add( "HUDPaint", "Shadowvortex", Shadowvortex)
	end
	if (SERVER) then
	if !self:IsValid() then return end
	local pos = self:GetPos()
	self.TotalList={}
	for k, v in pairs(ents.FindInSphere(pos,590)) do
		if v:IsNPC() then
			if v.pos == nil then
				v.pos=v:GetPos()
			end
			v.pos = v.pos-Vector(0,0,0.07)

			v:SetPos(v.pos)
			if v.pos == nil then
				v.pos=v:GetPos()
			end
			if v.accumilation == nil then 
				v.accumilation = 1
			end
			v:SetPos(Vector(v:GetPos().x,v:GetPos().y,v:GetPos().z-0.1))
			v.accumilation = v.accumilation+1
			if v.accumilation/1000 >= 1 then
				v.accumilation = 1000
				sound.Play("ambient/voices/m_scream1.wav", v:GetPos(), 100, 100, 1)
				v:Remove()
			end
		end
		if v:IsPlayer() and !(v==self.radowner) then
			if v.pos == nil then
				v.pos=v:GetPos()
			end
			v.pos = v.pos-Vector(0,0,0.07)

			v:SetPos(v.pos)
			if v.accumilation == nil then 
				v.accumilation = 1
			end
			v.accumilation = v.accumilation+1
			if v.accumilation/1000 >= 1 then
				if v:Alive() then
					v:Kill()
				end
				v.accumilation = 1000
			end
			v:SetRunSpeed(500-(v.accumilation/2.1))
			v:SetWalkSpeed(500-(v.accumilation/2.1))
			v:SetNWInt("contrast_shadow", v.accumilation/1000 )
			table.insert(self.Plylist,v)
			table.insert(self.TotalList, v )

		end
	end

	for k, v in pairs(self.TotalList) do
		if v:IsValid() then 
			if !table.HasValue(self.EntList,v) then
				if v:IsPlayer() then
					table.insert(self.EntList, v )
				end
			end
		end
	end
	for index, entlist_ply in pairs(self.EntList) do
		if entlist_ply:IsValid() then
			if !table.HasValue(self.TotalList, entlist_ply ) then
				if entlist_ply:IsValid() then
					table.remove(self.EntList, index)
					entlist_ply.accumilation=0
					entlist_ply:SetNWInt("contrast_shadow", 0 )
					entlist_ply:Freeze(false)
					entlist_ply:SetRunSpeed(500)
					entlist_ply:SetWalkSpeed(250)
				end
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
	if (CLIENT) then
		if (LocalPlayer():GetNWInt("Affected")) then
		end
	end
	if (SERVER) then
		for k, v in pairs(self.Plylist) do
			if v:IsValid() then
				if v:GetNWInt("Affected", 0) then
					v:SetNWInt("contrast_shadow", 0 )
					v.accumilation=0
					v:Freeze(false)
					v:SetRunSpeed(500)
					v:SetWalkSpeed(250)
					v.pos=nil
				end
			end
		end
	end
end
function ENT:Draw()
     return true
end
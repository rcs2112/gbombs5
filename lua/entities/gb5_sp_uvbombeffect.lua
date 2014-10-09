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
		 if self.RadRadius==nil then
			self.RadRadius=500
		 end
		 
     end
end

function ENT:Think()
	if (CLIENT) then
		function UvBomb()
			local tab = {}
			tab[ "$pp_colour_addr" ] = LocalPlayer():GetNWInt("Uv", 0)/2
			tab[ "$pp_colour_addg" ] = 0 - LocalPlayer():GetNWInt("Uv", 0)
			tab[ "$pp_colour_addb" ] = LocalPlayer():GetNWInt("Uv", 0)
			tab[ "$pp_colour_brightness" ] = 0
			tab[ "$pp_colour_contrast" ] = 1
			tab[ "$pp_colour_colour" ] = 1
			tab[ "$pp_colour_mulr" ] = 0 
			tab[ "$pp_colour_mulg" ] = 0 
			tab[ "$pp_colousr_mulb" ] = LocalPlayer():GetNWInt("Uv", 0) 
			DrawColorModify( tab )
		end
		hook.Add( "HUDPaint", "UvBomb", UvBomb)
	end
	if (SERVER) then
	if !self:IsValid() then return end
	local pos = self:GetPos()
	self.TotalList={}
	for k, v in pairs(ents.FindInSphere(pos,self.RadRadius)) do
		if v:IsPlayer() and !v:IsNPC() and v.hazsuited==false then
			if v.accumilation == nil then 
				v.accumilation = 1
			end
			if !v:IsOnFire() then
				v:Ignite(1, 0)
			end
			v.accumilation = v.accumilation+3
			if v.accumilation/1000 >= 1 then
				v.accumilation = 1000
				if v:Alive() then
					v:Kill()
				end
			end
			v:SetNWInt("Uv", v.accumilation/1000 )
			v:SetNWInt("Uved", 1)
			table.insert(self.Plylist,v)
			table.insert(self.TotalList, v )

		elseif v:IsNPC() && v:IsValid() then
			if v.accumilation == nil then 
				v.accumilation = 1
			end
			if !v:IsOnFire() then
				v:Ignite(4, 0)
			end
			v.accumilation = v.accumilation+3
			if v.accumilation/1000 >= 1 then
				v.accumilation = 1000
				if v:IsValid() then
					v:Remove()
				end
			end
		elseif v:GetClass()=="prop_physics" then
			v:Ignite(10, 0)
			timer.Simple(10.1, function()
				if v:IsValid() then
					v:Extinguish()
				end
			end)
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
					entlist_ply:SetNWInt("Uved", 0)
					entlist_ply:SetNWInt("Uv", 0 )
				end
			end
		end
	end
	self.Bursts = self.Bursts + 0.01
	if (self.Bursts >= 4) then
		self:Remove()
	end
	self:NextThink(CurTime() + 0.01)
	return true
	end
end
function ENT:OnRemove()
	if (CLIENT) then
		if (LocalPlayer():GetNWInt("Uved")) then
		end
	end
	if (SERVER) then
		for k, v in pairs(self.Plylist) do
			if v:IsValid() then
				if v:GetNWInt("Uved", 0) then
					v:SetNWInt("Uv", 0 )
					v.accumilation=0
				end
			end
		end
	end
end
function ENT:Draw()
     return true
end
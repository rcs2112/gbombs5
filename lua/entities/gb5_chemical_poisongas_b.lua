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
		 if self.Burst==nil then
			self.Burst = 10
		 end
		 
     end
end

function ENT:Think()
	if (CLIENT) then
		function PoisonGas()
			DrawMotionBlur( LocalPlayer():GetNWInt("addalpha", 0), LocalPlayer():GetNWInt("drawalpha", 0), LocalPlayer():GetNWInt("delay", 0) )
			local tab = {}
			tab[ "$pp_colour_addr" ] = 0 
			tab[ "$pp_colour_addg" ] = 0
			tab[ "$pp_colour_addb" ] = 0 
			tab[ "$pp_colour_brightness" ] = LocalPlayer():GetNWInt("contrast", 0)
			tab[ "$pp_colour_contrast" ] = 1
			tab[ "$pp_colour_colour" ] = 1
			tab[ "$pp_colour_mulr" ] = 0
			tab[ "$pp_colour_mulg" ] = 0
			tab[ "$pp_colousr_mulb" ] = 0 
			DrawColorModify( tab )
		end
		hook.Add( "HUDPaint", "PoisonGas", PoisonGas)
	end
	if (SERVER) then
	if !self:IsValid() then return end
	local pos = self:GetPos()
	self.TotalList={}
	for k, v in pairs(ents.FindInSphere(pos,self.RadRadius)) do
		if v:IsPlayer() and !v:IsNPC() and v.gasmasked==false then
			if v.accumilation == nil then 
				v.accumilation = 1
			end
			v.accumilation = v.accumilation+1
			if v.accumilation/1000 >= 1 then
				v.accumilation = 1000
			end
			v:SetRunSpeed(500-(v.accumilation/2.1))
			v:SetWalkSpeed(500-(v.accumilation/2.1))
			v:SetNWInt("delay", v.accumilation/2000  )
			v:SetNWInt("addalpha", v.accumilation/20000 )
			v:SetNWInt("drawalpha", v.accumilation/1100 )
			v:SetNWInt("contrast", v.accumilation/1000 )
			v:SetNWInt("Affected", 1)
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
					entlist_ply:SetNWInt("drawalpha", 0  )
					entlist_ply:SetNWInt("delay", 0  )
					entlist_ply:SetNWInt("Affected", 0)
					entlist_ply:SetNWInt("contrast", 0 )
					entlist_ply:SetRunSpeed(500)
					entlist_ply:SetWalkSpeed(250)
				end
			end
		end
	end
	self.Bursts = self.Bursts + 0.01
	if (self.Bursts >= self.Burst) then
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
					v:SetNWInt("contrast", 0 )
					v:SetNWInt("delay", 0)
					v.accumilation=0
					v:SetNWInt("drawalpha",0)
					v:SetRunSpeed(500)
					v:SetWalkSpeed(250)
				end
			end
		end
	end
end
function ENT:Draw()
     return true
end
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

sound.Add( {
	name = "shadow_drive",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100, 100},
	sound = "ambience/_cache_/bin_32/shadowdrive_loop.wav"
} )

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
		 self:SetNoDraw(true)
		 if self.RadRadius==nil then
			self.RadRadius=500
		 end	 
     end
end

function ENT:Think()
	if (CLIENT) then
		function Draw_Mod()
			local tab = {}
			tab[ "$pp_colour_addr" ] = 0 - LocalPlayer():GetNWInt("color", 0)/4
			tab[ "$pp_colour_addg" ] = 0 - LocalPlayer():GetNWInt("color", 0)/4
			tab[ "$pp_colour_addb" ] = 0 - LocalPlayer():GetNWInt("color", 0)/5
			tab[ "$pp_colour_brightness" ] = 0
			tab[ "$pp_colour_contrast" ] = 1
			tab[ "$pp_colour_colour" ] = 1
			tab[ "$pp_colour_mulr" ] = 0 
			tab[ "$pp_colour_mulg" ] = 0
			tab[ "$pp_colousr_mulb" ] = 0
			DrawColorModify( tab )
		end
		hook.Add( "HUDPaint", "Draw_Mod", Draw_Mod)
	end
	if (SERVER) then
	if !self:IsValid() then return end
	if !self.radowner:Alive() then
		self:Remove()
	end
	if self.radowner:IsValid() then 
		if self.initialised==nil then
			self.initialised=true
			self.radowner:EmitSound("shadow_drive", 100, 100)
		end
		self.radowner.shadowdrived = true
		self.pos = string.Explode( " ", tostring(self.radowner:GetPos()) )
		self:SetPos(Vector(self.pos[1],self.pos[2],self.pos[3]))
		
		local pos = self:GetPos()
		self.TotalList={}
		for k, v in pairs(ents.FindInSphere(pos,self.RadRadius)) do
			if v:IsPlayer() and !v:IsNPC() then
				if v.accumilation==nil then 
					v.accumilation = 0.5
				end
				v.accumilation = v.accumilation+0.5
				if v.accumilation/1000 >= 1 then
					v.accumilation = 1000
				end
				local dist = (self:GetPos() - v:GetPos()):Length()
				local relation = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
				v:SetNWInt("color", v.accumilation/1000 )
				v:SetNWInt("Affected", 1)
				table.insert(self.Plylist,v)
				table.insert(self.TotalList, v )

			end
		end
		for k, v in pairs(ents.FindInSphere(self:GetPos(),120)) do
			if v:GetClass()=="prop_combine_ball" then
				v:Remove()
			end
		end
		if self.radowner:Health() < 500 then
			self.radowner:SetHealth(self.radowner:Health() + 1)
		end
		if (self.radowner.shadowed==true) && ( self.radowner:KeyDown( IN_JUMP ) ) then
			self.radowner:SetMoveType( MOVETYPE_WALK )
			self.radowner:SetVelocity( Vector(0,0,15) )
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
			if !table.HasValue(self.TotalList, entlist_ply ) then
				if entlist_ply:IsValid() then
					table.remove(self.EntList, index)
					entlist_ply:SetNWInt("rad_relation", 0  )
					entlist_ply:SetNWInt("color", 0 )
					entlist_ply:SetNWInt("delay", 0)
					entlist_ply.accumilation=0
					entlist_ply:SetNWInt("drawalpha",0)
				end
			end
		end
	else
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
		if self.radowner:IsValid() then
			self.radowner:StopParticles()
			self.radowner.shadowdrived = false
			local player = self.radowner
			self.radowner:StopSound("shadow_drive")
		end
		
		for k, v in pairs(self.Plylist) do
			if v:IsValid() then
				v:SetNWInt("color", 0 )
				v:SetNWInt("delay", 0)
				v.accumilation=0
				v:SetNWInt("drawalpha",0)
				v:SetRunSpeed(500)
				v:SetWalkSpeed(250)
			end
		end
	end
end

function ENT:Draw()
     return true
end
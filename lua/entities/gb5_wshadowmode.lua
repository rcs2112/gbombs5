AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

sound.Add( {
	name = "whiteshadow",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100, 100},
	sound = "ambience/_cache_/bin_32/whiteshadow_mode_loop.wav"
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
	if (SERVER) then
	if !self:IsValid() then return end
	if !self.radowner:Alive() then
		self:Remove()
	end
	if self.radowner:IsValid() then 
		if self.initialised==nil then
			self.initialised=true
			timer.Simple(2, function()
				if !self.radowner:IsValid() then return end		
				self.radowner:EmitSound("ambience/_cache_/bin_32/whiteshadow_mode.wav", 100, 100)
			end)
			self.radowner:EmitSound("whiteshadow", 100, 100)
			
			
		end
		self.radowner.whiteshadowmode = true
		self.pos = string.Explode( " ", tostring(self.radowner:GetPos()) )
		self:SetPos(Vector(self.pos[1],self.pos[2],self.pos[3]))
		
		local pos = self:GetPos()
		self.TotalList={}

		for k, v in pairs(ents.FindInSphere(self:GetPos(),120)) do
			if v:GetClass()=="prop_combine_ball" then
				v:Remove()
			end
		end
		if self.radowner:Health() < 1500 then
			self.radowner:SetHealth(self.radowner:Health() + 10)
		end
		if ( self.radowner:KeyDown( IN_JUMP ) ) then
			self.radowner:SetMoveType( MOVETYPE_WALK )
			self.radowner:SetVelocity( Vector(0,0,15) )
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
			self.radowner:StopSound("whiteshadow")
		end
	end
end

function ENT:Draw()
     return true
end
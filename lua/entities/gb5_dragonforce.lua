AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

sound.Add( {
	name = "dragonforce",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100, 100},
	sound = "ambience/_cache_/bin_32/dragonforce.wav"
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
		 timer.Simple(1, function()
			self.radowner:EmitSound("dragonforce")
		 end)
		 timer.Simple(2.4, function()
			ParticleEffectAttach("shadow_dragonforce",PATTACH_POINT_FOLLOW,self.radowner,self.radowner:LookupAttachment("mouth")) 
		 end)
     end
end

function ENT:Think()
	if (SERVER) then
	if !self:IsValid() then return end
	if !self.radowner:Alive() then
		self:Remove()
	end
	if self.radowner:IsValid() then 
		self.radowner.dragonforce = true
		self.pos = string.Explode( " ", tostring(self.radowner:GetPos()) )
		self:SetPos(Vector(self.pos[1],self.pos[2],self.pos[3]))		
		local pos = self:GetPos()
		self.TotalList={}
		for k, v in pairs(ents.FindInSphere(self:GetPos(),120)) do
			if v:GetClass()=="prop_combine_ball" then
				v:Remove()
			end
			local phys = v:GetPhysicsObject()
			if phys:IsValid() && v!=self.radowner then
				local F_dir = (v:GetPos() - self:GetPos()):GetNormal() * 5
				if v:IsPlayer() && v:Alive() then
					v:SetMoveType( MOVETYPE_WALK )
					local F_dir = (v:GetPos() - self:GetPos()):GetNormal() * 25
					phys:SetVelocity(F_dir)
					
					
				else
					
					phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
					phys:AddVelocity(F_dir)
				end
			end
		end
		if self.radowner:Health() < 1000 then
			self.radowner:SetHealth(self.radowner:Health() + 1)
		end
		if (self.radowner.shadowed==true) && ( self.radowner:KeyDown( IN_JUMP ) ) then
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
			self.radowner.dragonforce = false
			local player = self.radowner
			self.radowner:StopSound("dragonforce")
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
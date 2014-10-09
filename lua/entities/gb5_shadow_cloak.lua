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
     end
end

function ENT:Think()
	if (SERVER) then
	if !self:IsValid() then return end
	if !self.radowner:Alive() then
		self:Remove()
	end
	if self.radowner:IsValid() then 
		self.pos = string.Explode( " ", tostring(self.radowner:GetPos()) )
		self:SetPos(Vector(self.pos[1],self.pos[2],self.pos[3]))
		if self.radowner.shadowed==true then	
			local pos = self.radowner:GetPos()
			local tracedata    = {}
			tracedata.start    = pos
			tracedata.endpos   = tracedata.start - Vector(0, 0, 55)
			tracedata.filter   = self.Entity
			local trace = util.TraceLine(tracedata)
			if trace.HitWorld then
				
				ParticleEffect("shadowdrive_shadow",trace.HitPos,Angle(0,0,0),nil)
			end
			for k, v in pairs( ents.GetAll() ) do
				if v:GetClass()=="worldspawn" or v:GetClass()=="gb5_shadowdrive" then return end
				ent1=self.radowner
				ent1:SetCustomCollisionCheck(true)
				ent2=v
				ent2:SetCustomCollisionCheck(true)
				function ShouldCollideHook( ent1, ent2 )
					if ( ent1:IsValid() and ent2:IsValid() )  then
						return false
					end 
				end
				hook.Add( "ShouldCollide", "ShouldCollideHook", ShouldCollideHook )
			end
		end
		if self.radowner.shadowed==false then
			for k, v in pairs( ents.GetAll() ) do
				if v:GetClass()=="worldspawn" or v:GetClass()=="gb5_shadowdrive" then return end
				ent1=self.radowner
				ent1:SetCustomCollisionCheck(true)
				ent2=v
				ent2:SetCustomCollisionCheck(true)
				
				function ShouldCollideHook( ent1, ent2 )
					if ( ent1:IsValid() and ent2:IsValid() )  then
						return true
					end 
				end
				hook.Add( "ShouldCollide", "ShouldCollideHook", ShouldCollideHook )
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
	if (SERVER) then	
		for k, v in pairs( ents.GetAll() ) do
			if v:GetClass()=="worldspawn" or v:GetClass()=="gb5_shadowdrive" then return end
			ent1=self.radowner
			ent1:SetCustomCollisionCheck(true)
			ent2=v
			ent2:SetCustomCollisionCheck(true)
			
			function ShouldCollideHook( ent1, ent2 )
				if ( ent1:IsValid() and ent2:IsValid() )  then
					return true
				end 
			end
			hook.Add( "ShouldCollide", "ShouldCollideHook", ShouldCollideHook )
		end
	end
end

function ENT:Draw()
     return true
end
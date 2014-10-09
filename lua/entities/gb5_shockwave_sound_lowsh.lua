AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  ""        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.GBOWNER                          =  nil            
ENT.MAX_RANGE                        = 0
ENT.SHOCKWAVE_INCREMENT              = 0
ENT.DELAY                            = 0
ENT.SOUND                            = ""

function ENT:Initialize()
     if (SERVER) then
		 self.FILTER                           = {}
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.CURRENTRANGE = 0
		 

     end
end

function ENT:Think()		
	 if (CLIENT) then
		if LocalPlayer():GetNWBool("waiting", false)==false then
			if LocalPlayer():GetNWBool("ran_pitch", nil)==true then
				if !(LocalPlayer():GetNWInt("maxsound_dist", nil)==0) then -- realistic dist sound volume
					local dist = (self:GetPos() - LocalPlayer():GetPos()):Length()
					local relation = math.Clamp(( LocalPlayer():GetNWInt("maxsound_dist", nil) - dist) / LocalPlayer():GetNWInt("maxsound_dist", nil), 0, 1)
					LocalPlayer():EmitSound(LocalPlayer():GetNWString("sound"), relation*100, math.random(80,120))
				else
					LocalPlayer():EmitSound(LocalPlayer():GetNWString("sound"), 100, math.random(80,120))
				end
			else
				if !(LocalPlayer():GetNWInt("maxsound_dist", nil)==0) then -- realistic dist sound volume
					local dist = (self:GetPos() - LocalPlayer():GetPos()):Length()
					local relation = math.Clamp(( LocalPlayer():GetNWInt("maxsound_dist", nil) - dist) / LocalPlayer():GetNWInt("maxsound_dist", nil), 0, 1)
					LocalPlayer():EmitSound(LocalPlayer():GetNWString("sound"), relation*100, 100)
				else
					LocalPlayer():EmitSound(LocalPlayer():GetNWString("sound"), 100, 100)
				end
			end
			
			LocalPlayer():SetNWBool("waiting", true)
			LocalPlayer():SetNWInt("maxsound_dist", nil)
			LocalPlayer():SetNWBool("ran_pitch", false)
		end
	 end
     if (SERVER) then
     if !self:IsValid() then return end
	 local pos = self:GetPos()
	 self.CURRENTRANGE = self.CURRENTRANGE+self.SHOCKWAVE_INCREMENT 
	 if(GetConVar("gb5_realistic_sound"):GetInt() >= 1) then
		 for k, v in pairs(ents.FindInSphere(pos,self.CURRENTRANGE)) do
			 if v:IsPlayer() then
				 if !(table.HasValue(self.FILTER,v)) then
					v:SetNWBool("waiting", true)
					v:SetNWBool("ran_pitch", false)
					v:SetNWInt("maxsound_dist", nil)
					v:SetNWBool("waiting", false)
					v:SetNWBool("ran_pitch", self.RandomPitch)
					v:SetNWInt("maxsound_dist", self.Maxsounddist)
					print(self.Maxsounddist)
					v:SetNWString("sound", self.SOUND)
					
					
					if self:GetVar("Shocktime") == nil then
						self.shocktime = 1
					else
						self.shocktime = self:GetVar("Shocktime")
					end
					if GetConVar("gb5_sound_shake"):GetInt()== 1 then
						util.ScreenShake( v:GetPos(), 5555, 555, self.shocktime, 500 )
					end
					table.insert(self.FILTER, v)
					
				 end
			 end
		 end
	 else
		if self:GetVar("Shocktime") == nil then
			self.shocktime = 1
		else
			self.shocktime = self:GetVar("Shocktime")
		end
	 	local ent = ents.Create("gb5_shockwave_sound_instant")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetPhysicsAttacker(ply)
		ent:SetVar("GBOWNER", self.GBOWNER)
		ent:SetVar("MAX_RANGE",50000)
		ent:SetVar("DELAY",0.01)
		ent:SetVar("Shocktime",self.shocktime)
		ent:SetVar("SOUND", self:GetVar("SOUND"))
		self:Remove()
	 end
	 self.Bursts = self.Bursts + 1
	 if (self.CURRENTRANGE >= self.MAX_RANGE) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + self.DELAY)
	 return true
	 end
end
function ENT:OnRemove()
	if SERVER then
		if self.FILTER==nil then return end
		for k, v in pairs(self.FILTER) do
			if !v:IsValid() then return end
			v:SetNWBool("waiting", true)
			v:SetNWBool("ran_pitch", nil)
		end
	end
end
function ENT:Draw()
     return false
end
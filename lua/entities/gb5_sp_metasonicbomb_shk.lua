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

if SERVER then
	function ENT:Initialize()  
		 self.FILTER = {}
		 self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		 self:SetSolid( SOLID_NONE )
		 self:SetMoveType( MOVETYPE_NONE )
		 self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.CURRENTRANGE = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
		 self.SOUND = self:GetVar("SOUND")
		 self.DEFAULT_PHYSFORCE  = self:GetVar("DEFAULT_PHYSFORCE")
		 self.DEFAULT_PHYSFORCE_PLYAIR  = self:GetVar("DEFAULT_PHYSFORCE_PLYAIR")
		 self.DEFAULT_PHYSFORCE_PLYGROUND = self:GetVar("DEFAULT_PHYSFORCE_PLYGROUND")
		 self.SHOCKWAVEDAMAGE = self:GetVar("SHOCKWAVE_DAMAGE")
		 self.allowtrace=true
		 self.Filter={}
	end
end
function ENT:Trace()
	if SERVER then
		if !self:IsValid() then return end
		if(GetConVar("gb5_decals"):GetInt() >= 1) then
		end
	end
end
function ENT:Think()		
     if (SERVER) then
     if !self:IsValid() then return end
	 local pos = self:GetPos()
	 self.CURRENTRANGE = self.CURRENTRANGE+self.SHOCKWAVE_INCREMENT
	 if self.allowtrace then
		self:Trace()
		self.allowtrace=false
	 end
	 for k, v in pairs(ents.FindInSphere(pos,self.CURRENTRANGE)) do
		 if (v:IsValid() or v:IsPlayer()) and (v.forcefielded==false or v.forcefielded==nil) then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 phys = v:GetPhysicsObjectNum(i)
				 if !(table.HasValue(self.Filter,v)) then
					 table.insert(self.Filter, v)
					 if (phys:IsValid()) then
						 local mass = phys:GetMass()
						 local F_ang = self.DEFAULT_PHYSFORCE
						 local dist = (pos - v:GetPos()):Length()
				
						 local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
						 local F_dir = (v:GetPos() - pos):GetNormal() * self.DEFAULT_PHYSFORCE 
						 phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
						 phys:AddVelocity(Vector(F_dir.x,F_dir.y,F_dir.z+math.random(1,1655)))
						 if(GetConVar("gb5_shockwave_unfreeze"):GetInt() >= 1) then
							 if !v.isWacAircraft then
								phys:Wake()
								phys:EnableMotion(true)
								constraint.RemoveAll(v)
							 end
						 end
						 if (v:GetClass()=="func_breakable" or class=="func_breakable_surf" or class=="func_physbox") then
							v:Fire("Break", 0)
						 end
					 end
					 if (v:IsPlayer()) then
						
						 v:SetMoveType( MOVETYPE_WALK )
						 
						 local mass = phys:GetMass()
						 local F_ang = self.DEFAULT_PHYSFORCE_PLYAIR
						 local dist = (pos - v:GetPos()):Length()
						 local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
						 local F_dir = (v:GetPos() - pos):GetNormal() * self.DEFAULT_PHYSFORCE_PLYAIR
						 v:SetVelocity(Vector(F_dir.x,F_dir.y,F_dir.z+math.random(1,1555)))
					 end

					 if (v:IsPlayer()) and v:IsOnGround() then
						 v:SetMoveType( MOVETYPE_WALK )
						 
						 local mass = phys:GetMass()
						 local F_ang = self.DEFAULT_PHYSFORCE_PLYGROUND
						 local dist = (pos - v:GetPos()):Length()
						 local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
						 local F_dir = (v:GetPos() - pos):GetNormal() * self.DEFAULT_PHYSFORCE_PLYGROUND	 
						 v:SetVelocity(Vector(F_dir.x,F_dir.y,F_dir.z+math.random(1,1555)))
					 end
				end
			 i = i + 1
			 end
		 end
 	 end
	 self.Bursts = self.Bursts + 1
	 if (self.CURRENTRANGE >= self.MAX_RANGE) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + self.DELAY)
	 return true
	 end
end

function ENT:Draw()
     return false
end
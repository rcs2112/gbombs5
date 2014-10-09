AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  ""        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.GBOWNER                          =  nil            
ENT.MAX_RANGE                        = 0
ENT.DELAY                            = 0
ENT.SOUND                            = ""
ENT.Burst                            = 0 
function ENT:Initialize()
     if (SERVER) then
		 self.FILTER                           = {}
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.CURRENTRANGE = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
		 self.SOUND = self:GetVar("SOUND")
		 sound.Play("ambience/_cache_/bin_32/shadoweruption.wav", self:GetPos(), 75, 100, 1)

     end
end

function ENT:Think(ply)		
     if (SERVER) then
     if !self:IsValid() then return end
	 local pos = self:GetPos()
	 for k, v in pairs(ents.FindInSphere(pos,317)) do
		 if (v:IsValid() or v:IsNPC() or v:IsPlayer()) then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 phys = v:GetPhysicsObjectNum(i)
				 if v:IsPlayer() && !(v==self.GBOWNER) then			
					local dmg = DamageInfo()
					dmg:SetDamage(math.random(1,5))
					dmg:SetDamageType(DMG_RADIATION)
					dmg:SetAttacker(self.GBOWNER)
					v:TakeDamageInfo(dmg)	
					local self_z = self:GetPos().z
					local player_z = v:GetPos().z
					local difference = player_z-self_z
					if difference > 135 then
						v:SetVelocity( Vector(0,0,v:GetVelocity().z*-1) )
					else
						v:SetVelocity( Vector(0,0,250) )	
					end
				 end

				 if (v:IsNPC()) then
					local dmg = DamageInfo()
					dmg:SetDamage(math.random(1,5))
					dmg:SetDamageType(DMG_BULLET)
					dmg:SetAttacker(self.GBOWNER)
					v:SetMoveType( MOVETYPE_STEP )
					v:TakeDamageInfo(dmg)	
					local self_z = self:GetPos().z
					local player_z = v:GetPos().z
					local difference = player_z-self_z
					if difference > 155 then		
						v:SetVelocity( Vector(0,0,v:GetVelocity().z*-1) )
						
					else
						v:SetVelocity( Vector(0,0,250) )	
					end	
				 end
			 i = i + 1
			 end
		 end
 	 end
	 self.Bursts = self.Bursts + 1
	 if (self.Bursts >= 50) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + 0.1)
	 return true
	 end
end

function ENT:Draw()
     return false
end
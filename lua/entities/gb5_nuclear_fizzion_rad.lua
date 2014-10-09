AddCSLuaFile()

DEFINE_BASECLASS( "gb5_nuclear_fission_rad_base" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.GBOWNER                          =  nil            
ENT.DAMAGE_MUL = 1
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
     end
end
function ENT:Think()
     if (SERVER) then
     if !self:IsValid() then return end
	 local pos = self:GetPos()
	 local dmg = DamageInfo()
	 dmg:SetDamage(math.random(1,2)*self.DAMAGE_MUL)
	 dmg:SetDamageType(DMG_RADIATION)
	 dmg:SetAttacker(self.GBOWNER)
	 for k, v in pairs(ents.FindInSphere(pos,400)) do
         if v:IsPlayer() or v:IsNPC() then
		    v:EmitSound("player/geiger3.wav", 100, 100)
		    v:TakeDamageInfo(dmg)
		    timer.Simple(math.random(), function()
		   	v:EmitSound("player/geiger2.wav", 100, 100)
			if !v:IsNPC() then
				v:ConCommand("Rad")
			end
		    end)
		 end
	 end
	 self.Bursts = self.Bursts + 1
	 if (self.Bursts >= 30) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + (math.random() + 1))
	 return true
	 end
end

function ENT:Draw()
     return false
end
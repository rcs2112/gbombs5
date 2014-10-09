AddCSLuaFile()

DEFINE_BASECLASS( "gb5_nuclear_fission_rad_base" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "T-Virus"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ZombieList={}
ZombieList[1]="npc_zombie"
ZombieList[2]="npc_fastzombie"
ZombieList[3]="npc_poisonzombie"

function ENT:Initialize()
	 if (SERVER) then
		 self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		 self:SetSolid( SOLID_NONE )
		 self:SetMoveType( MOVETYPE_NONE )
		 self:SetUseType( ONOFF_USE )
		 ParticleEffectAttach("zombie_blood",PATTACH_POINT_FOLLOW,self.zombie,0 ) 		 
	 end
end


function ENT:Think()	
	if (SERVER) then
	
	if !self:IsValid() then return end
	if self.zombie:IsValid() then
		pos = string.Explode( " ", tostring(self.zombie:GetPos()) )
		self:SetPos(Vector(pos[1],pos[2],pos[3]))
		for k, v in pairs(ents.FindInSphere(self:GetPos(),100)) do
			if v:IsPlayer() && v:Alive() && !v.isinfected then
				if v.gasmasked==false and v.hazsuited==false then
					local ent = ents.Create("gb5_chemical_tvirus_entity")
					ent:SetVar("infected", v)
					ent:SetPos( self:GetPos() ) 
					ent:Spawn()
					ent:Activate()
					v.isinfected = true
					ParticleEffectAttach("zombie_blood",PATTACH_POINT_FOLLOW,v,0 ) 
				end
			end
			if (v:IsNPC() && table.HasValue(npc_tvirus,v:GetClass()) && !v.isinfected) or (v.IsVJHuman==true && !v.isinfected) then
				local ent = ents.Create("gb5_chemical_tvirus_entity_npc")
				ent:SetVar("infected", v)
				ent:SetPos( self:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				v.isinfected = true
				ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
			end	
		end
	else
		self:Remove()
	end
	self:NextThink(CurTime() + 0.1)
	return true
	end
end

if (SERVER) then
	function ENT:OnRemove()
		if !self.zombie:IsValid() then return end
		self.zombie:StopParticles()
	end
end

function ENT:Draw()
     return false
end



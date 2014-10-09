AddCSLuaFile()

DEFINE_BASECLASS( "gb5_nuclear_fission_rad_base" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.GBOWNER                          =  nil            
ENT.DAMAGE_MUL = 1

function ENT:gb5_ragdoll(ply, mode) -- This is so fucking messy, but it's worth the 'weight'.
	if ( mode == 1 ) then
		if ( ply:Alive() && !ply.Ragdolled) then
			ply.spaz = false
			ply:DrawViewModel( false )
			ply:StripWeapons()
			ply.Ragdolled = true
			ply.AllowSpawn = false
			ply:Freeze(true)
			doll = ents.Create( "prop_ragdoll" )
			doll:SetModel( ply:GetModel() )
			doll:SetPos( ply:GetPos() )
			doll:SetAngles( ply:GetAngles() )
			doll:Spawn()
			doll:Activate()
			
			doll.owner = ply
			doll.shouldspaz = true
			doll.spazremove = false
			table.insert(self.RagDolls, doll)
			
			ply.Ragdoll = doll
			ply:Spectate( OBS_MODE_CHASE )
			ply:SpectateEntity( ply.Ragdoll )
			ply:SetParent( ply.Ragdoll )
			sound_list = {"vo/npc/male01/help01.wav","vo/npc/male01/moan01.wav","vo/npc/male01/goodgod.wav","vo/npc/male01/no01.wav","vo/npc/male01/no02.wav","vo/npc/male01/ohno.wav"}
			timer.Simple(0.1, function()
				ply:EmitSound(table.Random(sound_list), 50, 100)
			end)
		end
	else
		if ( ply:Alive() && ply.AllowSpawn ) then
			ply.Ragdolled = false
			ply:SetNoTarget( false )
			ply.AllowSpawn = true
			ply:SetParent()
			pos = string.Explode( " ", tostring(ply:GetPos()) )
			ply:Spawn()				
			ply:Freeze(false)
			ply:SetPos(Vector(pos[1],pos[2],pos[3]))
		end
		if doll:IsValid() then
			doll:Remove()
		end
		if ( !ply:Alive() && ply.AllowSpawn ) then
			
			ply.Ragdolled = false
			ply:SetNoTarget( false )
			ply:SetParent()
			ply:Freeze(false)
			
		end
		if doll:IsValid() then
			doll:Remove()
		end
	end
end


function ENT:Initialize()
	 if (SERVER) then
		 self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		 self:SetSolid( SOLID_NONE )
		 self:SetMoveType( MOVETYPE_NONE )
		 self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.GBOWNER = self:GetVar("GBOWNER")
		 self.AffectPlayers = {}
		 self.RagDolls = {}
	 end
end


function ENT:Think()
     if (SERVER) then
     if !self:IsValid() then return end
	 local pos = self:GetPos()
	 local dmg = DamageInfo()
	 for k, v in pairs(ents.FindInSphere(pos,300)) do
         if (v:IsPlayer() and v:Alive() and !(table.HasValue(self.AffectPlayers,v))) and v.gasmasked==false then		
			table.insert(self.AffectPlayers, v)
		 end
	 end
	 for k, v in pairs(self.AffectPlayers) do
		if !v.spaz and v:IsValid() then
			ply = v 
			ply.spaz = false
		    self:gb5_ragdoll(ply, 1)
		end
	 end
	 for k, v in pairs(self.RagDolls) do 
		if v:IsValid() then
			v.shouldspaz = false
			local phys = v:GetPhysicsObject()
			local i = 0
			if v:IsValid() && !v.spazremove then
				phys:AddAngleVelocity(Vector(math.random(1,1500),math.random(1,1500),math.random(1,1500)))
				timer.Simple(0.4, function()
					if v:IsValid() then
						phys:AddAngleVelocity(Vector(math.random(1,1500),math.random(1,1500),math.random(1,1500)))
						timer.Simple(0.4, function()
							if v:IsValid() then
								phys:AddAngleVelocity(Vector(math.random(1,1500),math.random(1,1500),math.random(1,1500)))
								timer.Simple(0.4, function()
									if v:IsValid() then
										phys:AddAngleVelocity(Vector(math.random(1,1500),math.random(1,1500),math.random(1,1500)))
										timer.Simple(0.4, function()
											if v:IsValid() then
												phys:AddAngleVelocity(Vector(math.random(1,1500),math.random(1,1500),math.random(1,1500)))
												timer.Simple(0.4, function()
													if v:IsValid() then
														phys:AddAngleVelocity(Vector(math.random(1,1500),math.random(1,1500),math.random(1,1500)))
													end
												end)
											end
										end)
									end
								end)
							end
						end)
					end
				end)
			end												
		end
	end

	 self.Bursts = self.Bursts + 1
	 if (self.Bursts >= 44) then
		 for k, v in pairs(self.AffectPlayers) do
			if v:IsValid() then
				ply = v 
				ply.AllowSpawn = true
				self:gb5_ragdoll(ply, 0)
				v.Ragdolled = false
				v:Freeze(false)
			end
		 end
	     self:Remove()
	 end
	 self:NextThink(CurTime() + 0.5)
	 return true
	 end
end
if SERVER then
	function ENT:OnRemove()
		for k, v in pairs(self.AffectPlayers) do
			if v:IsValid() then
				ply = v 
				ply.AllowSpawn = true
				self:gb5_ragdoll(ply, 0)
				v.Ragdolled = false
				for k, v in pairs(self.RagDolls) do
					if v:IsValid() && v.owner==ply then
						v:Remove()
					end
				end
			else
				for k, ragdoll in pairs(self.RagDolls) do
					if !ragdoll.owner:IsValid() && ragdoll:IsValid() then
						ragdoll:Remove()
					end
				end
			end
		 end
	end
end

function ENT:Draw()
     return false
end
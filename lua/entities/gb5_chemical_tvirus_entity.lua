AddCSLuaFile()

DEFINE_BASECLASS( "gb5_nuclear_fission_rad_base" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "T-Virus"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

sound.Add( {
	name = "tvirus",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 100,
	pitch = {100, 100},
	sound = "gbombs_5/tvirus_infection/ply_infection.mp3"
} )

ZombieList={}
ZombieList[1]="npc_zombie"
ZombieList[2]="npc_fastzombie"
ZombieList[3]="npc_poisonzombie"

ZombieList2={}
ZombieList2[1]="npc_vj_nmrih_walkmalez"
ZombieList2[2]="npc_vj_nmrih_walkfemalez"
ZombieList2[3]="npc_vj_nmrih_runmalez"
ZombieList2[4]="npc_vj_nmrih_runfemalez"

function ENT:Initialize()
	 if (SERVER) then
		 self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		 self:SetSolid( SOLID_NONE )
		 self:SetMoveType( MOVETYPE_NONE )
		 self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self:SetNetworkedString("infected", self:GetVar("infected"))
		 self.infected = self:GetVar("infected")
		 self.infected:SetNWBool( "Zombie_1", true)
		 self.infected:SetNWBool( "Zombie_1_Active", false)
		 self.infected:SetNWBool( "Zombie_2", true)
		 self.infected:SetNWBool( "Clear_HUD", false)
		 self.playsound = 1
		 self.RunSpeed = 500
		 self.WalkSpeed = 250
		 self.R = 255
		 self.G = 255
		 self.B = 255
		 
		 
	 end
end


function ENT:Think()	
	if (CLIENT) then
		if LocalPlayer()==self:GetNetworkedString("infected", false) then			
			if (LocalPlayer():GetNWBool( "Zombie_1", false )) then
				LocalPlayer():EmitSound("tvirus")
				LocalPlayer():SetNWBool( "Zombie_1", false)
				function Zombification()
					LocalPlayer():SetNWBool( "Zombie_1_Active", true)
					local tex = surface.GetTextureID("hud/infection")
					surface.SetTexture(tex)
					surface.SetDrawColor( 255, 255, 255, alpha );
					if (interval <= CurTime()) && (alpha < 255) then
						interval = CurTime() + 0.5
						alpha = alpha + 2
					end
					if (alpha > 255) then
						alpha = 255
						interval = CurTime() + 0.5
					end
					surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
				end
				hook.Add( "HUDPaint", "Zombification", Zombification)
			end
			if (LocalPlayer():GetNWBool( "Zombie_2", false )) then
				LocalPlayer():SetNWBool( "Zombie_2", false)
				function Zombification_1()
					local tab = {}
					tab[ "$pp_colour_addr" ] = 0
					tab[ "$pp_colour_addg" ] = 0
					tab[ "$pp_colour_addb" ] = 0
					tab[ "$pp_colour_brightness" ] = 0
					tab[ "$pp_colour_contrast" ] = 1-contrast
					tab[ "$pp_colour_colour" ] = 1-color_mod
					tab[ "$pp_colour_mulr" ] = 0
					tab[ "$pp_colour_mulg" ] = 0
					tab[ "$pp_colousr_mulb" ] = 0 
					DrawColorModify( tab )

					if (interval <= CurTime()) then
						interval = CurTime() + 0.1
						color_mod = color_mod + 0.01
						contrast = contrast + 0.001
					end
					if (color_mod > 1) then
						color_mod = 1
						interval = CurTime() + 0.1
					end
					if (contrast > 1) then
						contrast = 1
						interval = CurTime() + 0.1
					end
				end
				timer.Simple(8, function()
					if (LocalPlayer():GetNWBool( "Zombie_1_Active", false )) then	
						hook.Add( "RenderScreenspaceEffects", "Zombification_1", Zombification_1 )
					end
				end)
			end
		end
	end
	if (SERVER) then
	if !self:IsValid() then return end
	if !self.infected:IsValid() then -- doesnt fucking work
		self:Remove()
	end
	if !self.infected:IsValid() then return end
	self.R = self.R-0.15
	self.G = self.G-0.2
	self.B = self.B-0.2
	self.infected:SetColor(Color(self.R,self.G,self.B,255))
	self:SetPos(Vector(self.infected:GetPos().x,self.infected:GetPos().y,self.infected:GetPos().z))
	self.Bursts = self.Bursts + 1
	self.infected:SetRunSpeed(250-(self.Bursts/5))
	self.infected:SetWalkSpeed(250-(self.Bursts/5))
	for k, v in pairs(ents.FindInSphere(self:GetPos(),100)) do
		if v:IsPlayer() && v:Alive() && !v.isinfected then
			local ent = ents.Create("gb5_chemical_tvirus_entity")
			ent:SetVar("infected", v)
			ent:SetPos( self:GetPos() ) 
			ent:Spawn()
			ent:Activate()
			v.isinfected = true
			ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
		end
		if (v:IsNPC() && table.HasValue(npc_tvirus,v:GetClass()) && !v.isinfected) or (v.IsVJHuman==true && !v.isinfected) then
			if v.gasmasked==false and v.hazsuited==false then
				local ent = ents.Create("gb5_chemical_tvirus_entity_npc")
				ent:SetVar("infected", v)
				ent:SetPos( self:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				v.isinfected = true
				ParticleEffectAttach("zombie_blood",PATTACH_ABSORIGIN_FOLLOW,v, 1) 
			end
		end	
	end
	if (self.Bursts >= 1140) && (self.playsound==1) then 
		if !self:IsValid() then return end
		self.playsound = 0 
		self.infected:EmitSound("gbombs_5/tvirus_infection/infection_final.wav")
	end
	if (self.Bursts >= 1200) then -- Zombie time hehe
		if !self:IsValid() then return end
		if (file.Exists( "lua/autorun/vj_nmrih_autorun.lua", "GAME" )) && GetConVar("gb5_nmrih_zombies"):GetInt()== 1 then
			local ent = ents.Create(table.Random(ZombieList2)) -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			if GetConVar("gb5_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gb5_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			
			self.infected:SetNWBool("Clear_HUD", true)
			self.infected:Kill()
			self:Remove()
		else
			local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			if GetConVar("gb5_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gb5_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			
			
			self.infected:SetNWBool("Clear_HUD", true)
			self.infected:Kill()
			self:Remove()
		end
    end		
		
	if !self.infected:Alive() or !self.infected:IsValid() then
		self.infected:SetNWBool("Clear_HUD", true)
		if (file.Exists( "lua/autorun/vj_nmrih_autorun.lua", "GAME" )) && GetConVar("gb5_nmrih_zombies"):GetInt()== 1 then
			local ent = ents.Create(table.Random(ZombieList2)) -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			if GetConVar("gb5_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gb5_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			
			self.infected:SetNWBool("Clear_HUD", true)
			self.infected:Kill()
			self:Remove()
		else
			local ent = ents.Create(table.Random(ZombieList)) -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			if GetConVar("gb5_zombie_strength"):GetInt() == 0 then
				ent:SetHealth(500)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == 1 then
				ent:SetHealth(1000)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == 2 then
				ent:SetHealth(2000)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == -1 then
				ent:SetHealth(250)
			elseif GetConVar("gb5_zombie_strength"):GetInt() == -2 then
				ent:SetHealth(175)
			else
				ent:SetHealth(500)
			end
			local z_ent = ents.Create("gb5_chemical_tvirus_entity_z")
			z_ent:SetVar("zombie", ent)
			z_ent:SetPos( ent:GetPos() ) 
			z_ent:Spawn()
			z_ent:Activate()
			
			self.infected:SetNWBool("Clear_HUD", true)
			self.infected:Kill()
			self:Remove()
		end
	end
	
	self:NextThink(CurTime() + 0.1)
	return true
	end
end

if (SERVER) then
	function ENT:OnRemove()
		if !self.infected:IsValid() then return end
		local infected_player = self.infected
		infected_player.isinfected = false
		self.infected:SetNWBool( "Clear_HUD", true)
		self.infected:SetNWBool( "Zombie_1_Active", false)
		self.infected:SetRunSpeed(500)
		self.infected:SetWalkSpeed(250)
		infected_player:StopParticles()
		infected_player:SetColor(Color(255,255,255))
	end
end

if (CLIENT) then
	function ENT:OnRemove()
		if LocalPlayer()==self:GetNetworkedString("infected", false) then
			hook.Remove( "HUDPaint", "Zombification", Zombification )
			hook.Remove("RenderScreenspaceEffects", "Zombification_1", Zombification_1 )
			LocalPlayer():SetNWBool( "Clear_HUD", false)
			alpha = 0
			color_mod = 0
			contrast = 0
			LocalPlayer():ConCommand("stopsound")
			LocalPlayer():SetNWBool( "Zombie_1_Active", false)
		end
	end
end

function ENT:Draw()
     return false
end



if (CLIENT) then
	interval = 1
	alpha = 0
	color_mod = 0
	contrast = 0
end

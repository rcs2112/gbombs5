AddCSLuaFile()

DEFINE_BASECLASS( "gb5_nuclear_fission_rad_base" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "T-Virus"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

function ENT:Initialize()
	if CLIENT then
		SoundList={}
		SoundList[1]="gbombs_5/scp008/voice0.mp3"
		SoundList[2]="gbombs_5/scp008/voice1.mp3"
		SoundList[3]="gbombs_5/scp008/voice2.mp3"
		SoundList[4]="gbombs_5/scp008/voice3.mp3"
		SoundList[5]="gbombs_5/scp008/voice4.mp3"
		SoundList[6]="gbombs_5/scp008/voice5.mp3"
		SoundList[7]="gbombs_5/scp008/voice6.mp3"
		sound.Add( {
			name = "scp008",
			channel = CHAN_STATIC,
			volume = 1.0,
			level = 100,
			pitch = {100, 100},
			sound = "gbombs_5/scp008/scp_ambient.mp3"
		} )

	end
	 if (SERVER) then
		 self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
		 self:SetSolid( SOLID_NONE )
		 self:SetMoveType( MOVETYPE_NONE )
		 self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0 
		 self:SetNoDraw(true)
		 if self.infected.infection_percent==nil then
			self.infected.infection_percent=0
		 end
		 if self.infected.screen_percent==nil then
			self.infected.screen_percent=0
		 end
		 self.eat=false
	 end
end
 
if CLIENT then  
	net.Receive( "gbombs5_scp_2", function( len )   
		LocalPlayer():StopSound("scp008")
		set_var=nil
		alpha = 0
		invalpha = 0
		alpha_blur = 0
		alpha_invblur = 0
	end)
end
if CLIENT then  
	net.Receive( "gbombs5_scp_3", function( len )  
		LocalPlayer():StopSound("scp008")
	end)
	net.Receive( "gbombs5_scp", function( len )    
		local net_float = net.ReadFloat()
		local net_float_2 = net.ReadFloat()
		if net_float > 177.5 && (LocalPlayer().disallowsound2==false or LocalPlayer().disallowsound2==nil) then
			surface.PlaySound("gbombs_5/scp008/scp_99percent.wav")
			LocalPlayer().disallowsound2=true
		end
		if net_float > 85 && (LocalPlayer().disallowsound==false or LocalPlayer().disallowsound==nil) then
			LocalPlayer().disallowsound=true
			LocalPlayer():EmitSound("scp008")
			if net_float>0 && !(net_float==nil) then
				invalpha = 1
				alpha_invblur = 1
				alpha = 1
				alpha_blur = 1
				timer.Simple(math.random(2,40), function()
					if net_float>0 && !(net_float==nil) then
						function SCP008_ANON()
							DrawMotionBlur( 0.09, alpha_invblur, 0)
							alpha_invblur = alpha_invblur - 0.005
							local tex = surface.GetTextureID("hud/scp_anomaly")
							surface.SetTexture(tex)
							if net_float_2==nil then
							surface.SetDrawColor( 255, 255, 255, 0 );
							else
								surface.SetDrawColor( 255, 255, 255, math.random(1,255) );
							end
							surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
						end
						hook.Add( "HUDPaint", "SCP008_ANON", SCP008_ANON)
						hook.Add( "HUDPaint", "SCP008_INVFLASH", SCP008_INVFLASH)
						if math.random(1,2)==1 then
							surface.PlaySound("gbombs_5/scp008/scp_scare_1.wav")
						else
							surface.PlaySound("gbombs_5/scp008/scp_scare_2.wav")
						end
						timer.Simple(6, function()
							hook.Remove( "HUDPaint", "SCP008_INVFLASH", SCP008_INVFLASH)
						end)
						timer.Simple(0.5, function()
							hook.Remove( "HUDPaint", "SCP008_ANON", SCP008_ANON)
						end)
					end
				end)
				function SCP008_FLASH()
					DrawMotionBlur( 0.09, alpha, 0)
					alpha = alpha_blur - 0.003
					alpha_blur = alpha_blur - 0.003
					if alpha < 0.01 then
						alpha = 0
					end
					local tab = {}
					tab[ "$pp_colour_addr" ] = 0
					tab[ "$pp_colour_addg" ] = 0
					tab[ "$pp_colour_addb" ] = 0
					tab[ "$pp_colour_brightness" ] = alpha
					tab[ "$pp_colour_contrast" ] = 1+alpha
					tab[ "$pp_colour_colour" ] = 1
					tab[ "$pp_colour_mulr" ] = 0
					tab[ "$pp_colour_mulg" ] = 0
					tab[ "$pp_colousr_mulb" ] = 0 
					DrawColorModify( tab )
				end
				hook.Add( "HUDPaint", "SCP008_FLASH", SCP008_FLASH)
				function SCP008_INVFLASH()
					invalpha = invalpha - 0.003
					if alpha < 0.01 then
						alpha = 0
					end
					local tab = {}
					tab[ "$pp_colour_addr" ] = 0
					tab[ "$pp_colour_addg" ] = 0
					tab[ "$pp_colour_addb" ] = 0
					tab[ "$pp_colour_brightness" ] = -1*invalpha
					tab[ "$pp_colour_contrast" ] = 1-invalpha
					tab[ "$pp_colour_colour" ] = 1
					tab[ "$pp_colour_mulr" ] = 0
					tab[ "$pp_colour_mulg" ] = 0
					tab[ "$pp_colousr_mulb" ] = 0 
					DrawColorModify( tab )
				end
				
				timer.Simple(6, function()
					hook.Remove( "HUDPaint", "SCP008_FLASH", SCP008_FLASH)
				end)
			end					
		end
		if net_float < 85 then
			if LocalPlayer().disallowsound==true then
				LocalPlayer().disallowsound=false
			end
			if LocalPlayer().disallowsound2==true then
				LocalPlayer().disallowsound2=false
			end
		end
		function SCP008()
			local tex = surface.GetTextureID("hud/scp_infection")
			surface.SetTexture(tex)
			if net_float_2==nil or net_float==0 then	
				surface.SetDrawColor( 255, 255, 255, 0 );
				local tab = {}
				tab[ "$pp_colour_addr" ] = 0
				tab[ "$pp_colour_addg" ] = 0
				tab[ "$pp_colour_addb" ] = 0
				tab[ "$pp_colour_brightness" ] = 0
				tab[ "$pp_colour_contrast" ] = 1
				tab[ "$pp_colour_colour" ] = 1
				tab[ "$pp_colour_mulr" ] = 0
				tab[ "$pp_colour_mulg" ] = 0
				tab[ "$pp_colousr_mulb" ] = 0 
				DrawColorModify( tab )
			else
				surface.SetDrawColor( 255, 255, 255, net_float_2 );
				local tab = {}
				tab[ "$pp_colour_addr" ] = 0-(net_float_2/850)
				tab[ "$pp_colour_addg" ] = 0-(net_float_2/350)
				tab[ "$pp_colour_addb" ] = 0-(net_float_2/350)
				tab[ "$pp_colour_brightness" ] = 0
				tab[ "$pp_colour_contrast" ] = 1-(net_float_2/300)
				tab[ "$pp_colour_colour" ] = 1-(net_float_2/700)
				tab[ "$pp_colour_mulr" ] = 0
				tab[ "$pp_colour_mulg" ] = 0
				tab[ "$pp_colousr_mulb" ] = 0 
				DrawColorModify( tab )
				DrawMotionBlur( 0.09, 0+(net_float_2/250), 0)
			end
			
			surface.DrawTexturedRect( 0, 0, ScrW(), ScrH() )
		end
		hook.Add( "HUDPaint", "SCP008", SCP008)

		if math.random(1,1000-math.Round(net_float*2))==2 then
			surface.PlaySound(table.Random(SoundList))
		end		
	end ) 
end

function ENT:Think()	
	if SERVER then
		print(self.infected.infection_percent)
		if !self.infected:Alive() or !self.infected:IsValid() then -- Checking if the infected person is alive, and or exists.
			self:Remove()
		end
		
		self:SetPos(Vector(self.infected:GetPos().x,self.infected:GetPos().y,self.infected:GetPos().z)) -- setting position of this infection entity
		self.infected.infection_percent=self.infected.infection_percent+0.01 -- Updating infection percentage

		if self.infected.infection_percent>60 && self.infected:Health()<100 then
			self.infected:SetHealth(self.infected:Health() + math.random(20,105)/100) -- Here we add the health. Notice that I have math.random/100 - It's there to make regeneration slow and random
			
		end	
		if self.infected.infection_percent>80 then
			self.infected.screen_percent = self.infected.screen_percent+0.0280
		end
		
		if self.eat==true then
			
			if self.infected.infection_percent>0.1 then
				self.infected.infection_percent=self.infected.infection_percent-1
			end
			if self.infected.screen_percent>0.1 then	
				self.infected.screen_percent = self.infected.screen_percent-1
			end
			if self.infected.infection_percent<=0.1 && self.infected.screen_percent<=0.1 then
				self.eat=false
				self.alloweat=false
			end
		end
		if self.infected.infection_percent>120 then
			for k, v in pairs(ents.FindInSphere(self.infected:GetPos(), 800)) do
				if v:IsNPC() then
					v:AddEntityRelationship(self.infected, D_HT, 1 )
				end
			end
			for k, v in pairs(ents.FindInSphere(self.infected:GetPos(),60)) do
				if v:IsNPC() && (v.died==false or v.died==nil) && (self.alloweat==false or self.alloweat==nil) then
					self.alloweat=true
					self.eat=true
					sound.Play("ambient/creatures/town_child_scream1.wav", v:GetPos(),70, 100)
					sound.Play("ambient/voices/player/damage2.wav.wav", v:GetPos(),90, 100)
					v.died=true
					local pos = v:GetPos()
					local tracedata    = {}
					tracedata.start    = pos
					tracedata.endpos   = tracedata.start - Vector(0, 0, 100)
					tracedata.filter   = self.Entity
					local trace = util.TraceLine(tracedata)					
					util.Decal( "Blood", tracedata.start, tracedata.endpos )
					ParticleEffectAttach("blood_explosion",PATTACH_POINT_FOLLOW,v,v:LookupAttachment("mouth") )
					self.infected:EmitSound("gbombs_5/arm/pie_eat.mp3", 80, 100)
					
					
					local ent = ents.Create("prop_physics")
					ent:SetModel("models/Gibs/HGIBS.mdl")
					ent:SetPos( v:GetPos() ) 
					ent:Spawn()
					ent:Activate()
					
					timer.Simple(10, function()
						if ent:IsValid() then 
							ent:Remove()
						end
					end)
					timer.Simple(0.3, function()
						if v:IsValid() then
							
							v:Remove()
						end
					end)
				elseif v:IsPlayer() && v:Alive() && !(v==self.infected) && (self.alloweat==false or self.alloweat==nil) then
					net.Start( "gbombs5_scp_3")  		
					net.Send(self.infected) 
					self.alloweat=true
					self.eat=true
					sound.Play("ambient/creatures/town_child_scream1.wav", v:GetPos(),70, 100)
					sound.Play("ambient/voices/player/damage2.wav.wav", v:GetPos(),90, 100)
					v:SetModel("models/Humans/Charple03.mdl")
					local pos = v:GetPos()
					local tracedata    = {}
					tracedata.start    = pos
					tracedata.endpos   = tracedata.start - Vector(0, 0, 100)
					tracedata.filter   = self.Entity
					local trace = util.TraceLine(tracedata)					
					util.Decal( "Blood", tracedata.start, tracedata.endpos )
					ParticleEffectAttach("blood_explosion",PATTACH_POINT_FOLLOW,v,v:LookupAttachment("mouth") )
					self.infected:EmitSound("gbombs_5/arm/pie_eat.mp3", 80, 100)
					self.infected.infection_percent=self.infected.infection_percent-1
					
					local ent = ents.Create("prop_physics")
					ent:SetModel("models/Gibs/HGIBS.mdl")
					ent:SetPos( v:GetPos() ) 
					ent:Spawn()
					ent:Activate()
					v:Kill()
					timer.Simple(10, function()
						if ent:IsValid() then 
							ent:Remove()
						end
					end)
				elseif v:GetClass()=="prop_ragdoll" && (v.died==false or v.died==nil) && (self.alloweat==false or self.alloweat==nil) then 
					net.Start( "gbombs5_scp_3")  		
					net.Send(self.infected)    
					self.alloweat=true
					self.eat=true
					v:EmitSound("ambient/creatures/town_child_scream1.wav",70, 100)
					v:EmitSound("ambient/voices/player/damage2.wav.wav", 90, 100)
					v:SetModel("models/Humans/Charple03.mdl")
					v.died=true
					local pos = v:GetPos()
					local tracedata    = {}
					tracedata.start    = pos
					tracedata.endpos   = tracedata.start - Vector(0, 0, 100)
					tracedata.filter   = self.Entity
					local trace = util.TraceLine(tracedata)					
					util.Decal( "Blood", tracedata.start, tracedata.endpos )
					ParticleEffectAttach("blood_explosion",PATTACH_POINT_FOLLOW,v,v:LookupAttachment("mouth") )
					self.infected:EmitSound("gbombs_5/arm/pie_eat.mp3", 80, 100)
					
					
					local ent = ents.Create("prop_physics")
					ent:SetModel("models/Gibs/HGIBS.mdl")
					ent:SetPos( v:GetPos() ) 
					ent:Spawn()
					ent:Activate()
					timer.Simple(10, function()
						if ent:IsValid() then 
							ent:Remove()
						end
					end)
					
					timer.Simple(0.3, function()
						if v:IsValid() then
							
							v:Remove()
						end
					end)
				end
				
			end
		end
		if self.infected.infection_percent>176 then
			self.infected:SetModel("models/Humans/corpse1.mdl")
		end
		if self.infected.infection_percent>180 then
			self.infected.infection_percent=0
			self.infected.infection_percent=0
			self.infected:Kill()
			local ent = ents.Create("npc_fastzombie") -- This creates our zombie entity
			ent:SetPos(self.infected:GetPos())
			ent:Spawn() 
			ent:SetHealth(2500)
			self:Remove()
			
		end
		net.Start( "gbombs5_scp")  
			net.WriteFloat(math.Round(self.infected.infection_percent))
			net.WriteFloat(self.infected.screen_percent)
			net.WriteBit( false )   			
		net.Send(self.infected)    
		self:NextThink(CurTime() + 0.01)
		return true
	end
end


function ENT:Draw()
     return false
end

function ENT:OnRemove()
	if SERVER then
		if self.infected:IsValid() then
			self.infected.isinfected=false
			self.infected.infection_percent=0
			self.infected.screen_percent=0
			net.Start( "gbombs5_scp_2")     
			net.Send(self.infected)       
			net.Start( "gbombs5_scp")    
				net.WriteFloat( 0 )    
				net.WriteFloat( 0 )    
				net.WriteBit( true )     
			net.Send(self.infected)    
			for k, v in pairs(ents.FindInSphere(self.infected:GetPos(),55560)) do
				if v:IsNPC() && v:IsValid() then
					v:AddEntityRelationship(self.infected, D_FR, 1 )
				end
			end
		end
	end
end


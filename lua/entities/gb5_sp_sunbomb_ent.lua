AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 =  false       
ENT.AdminSpawnable		             =  true
ENT.PrintName		                 =  ""        
ENT.Author			                 =  ""      
ENT.Contact			                 =  "" 

ENT.PrintName		                 =  "Star"

Sounds={}
Sounds[0]=""
Sounds[1]="gbombs_5/sunbomb/sun_start.mp3"
Sounds[2]="gbombs_5/sunbomb/bluesun_start.mp3"
Sounds[3]="gbombs_5/sunbomb/sun_rumble.mp3"
Sounds[4]="gbombs_5/sunbomb/final_stage.mp3"
Sounds[5]="gbombs_5/sunbomb/final_stage_collapse.mp3"
Sounds[6]="gbombs_5/sunbomb/supernova.mp3"

RockModels={}
RockModels[0]="models/props/cs_militia/militiarock01.mdl"
RockModels[1]="models/props/cs_militia/militiarock02.mdl"
RockModels[2]="models/props/cs_militia/militiarock03.mdl"
RockModels[3]="models/props/cs_militia/militiarock05.mdl"
RockModels[4]="models/props_canal/rock_riverbed01d.mdl"
function ENT:Initialize()
	if (SERVER) then
		self:SetModel( "models/XQM/Rails/gumball_1.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_NONE )
		self:SetUseType( ONOFF_USE ) -- doesen't fucking work
		local phys = self:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:SetMass(50000)
		end 
		self.Tick=0
		self.AllowSound=false
		self.Props={}
		ParticleEffectAttach("sun_bomb",PATTACH_POINT_FOLLOW,self,0 ) 
		self.AsteroidUpdate_allow=true
		self.dolightness=nil
		self.dodarkness=nil
		self.darkness=0
		self.lightness=0
		self.plus=nil
		self.minus=nil
		for i=0, (55-1) do -- Rocks!
			 local ent1 = ents.Create("gb5_sp_sunbomb_rock") 
			 ent1:SetPos( self:GetPos() ) 
			 ent1:SetModel( table.Random(RockModels) )
			 ent1:Spawn()
			 ent1.vec_buffer=ent1:GetPos()
			 ent1.index=i 
			 ent1.offset_orbit = math.random(2000,4000)
			 ent1:SetModelScale( self:GetModelScale() + math.random(1,5), 0 )	
			 
		     -- Physics
			 local phys = ent1:GetPhysicsObject()
			 phys:EnableCollisions( false )
			 timer.Simple(4, function()
				if phys:IsValid() then
					phys:EnableCollisions( true )
				end
			end)
			 phys:SetMass(math.random(1000,10000))	 			 
			 table.insert(self.Props, ent1)
			 -- End	
		end
	end
end

function ENT:EventSound( event, shocktime ) 
	local ent = ents.Create("gb5_shockwave_sound_instant")
	ent:SetPos( self:GetPos() ) 
	ent:Spawn()
	ent:Activate()
	ent:SetVar("GBOWNER", self.GBOWNER)
	ent:SetVar("MAX_RANGE",50000)
	ent:SetVar("DELAY",0.01)
	ent:SetVar("Shocktime", shocktime)
	ent:SetVar("SOUND", Sounds[event])
end

function ENT:InnerCorona(corona)
	-- If the player is inside the sun, we do...
	for k, v in pairs(ents.FindInSphere(self:GetPos(),corona)) do
		if v:IsPlayer() && v:Alive() then
			v:Ignite(1,0)
			v:Kill()
			v:SetModel("models/Gibs/HGIBS.mdl")
			
		elseif v:IsNPC() then
			v:Ignite(1,0)
			local dmg = DamageInfo()
			dmg:SetDamage(math.random(25,25553))
			dmg:SetDamageType(DMG_BURN)
			if self.GBOWNER == nil then
				self.GBOWNER = table.Random(player.GetAll())
			end
			if !self.GBOWNER:IsValid() then
				self.GBOWNER = table.Random(player.GetAll())
			end
			dmg:SetAttacker(self.GBOWNER)
			v:TakeDamageInfo(dmg)
		elseif !v:IsPlayer() and !v:IsNPC() and v:GetPhysicsObject():IsValid() and v!=self and v:GetClass()!="gb5_sp_sunbomb_rock" then
			v:Ignite(1,0)
			v:Remove()
			
		end
	end
	
	-- If the player is about in 2x diameter of the sun then we do asteroidism shiz
	for k, v in pairs(ents.FindInSphere(self:GetPos(),(corona*4))) do
		if !table.HasValue(self.Props, v) and v!=self then	
		
			if v.orbital_owner==nil or !v.orbital_owner:IsValid() then
				v.orbital_owner=self
				v.vec_buffer=v:GetPos()
				v.index=math.random(2,12)  -- Random orbit speed
				v.offset_orbit = math.random(2000,5000)
			end
			
			if v.orbital_owner==self then
				phys = v:GetPhysicsObject()
				if phys:IsValid() then
					local vector_difference = v:GetPos()-v.vec_buffer
					local complete_vector = Vector(0,0,0)
					local corona_mod = self.corona
					if corona_mod > 0 and corona_mod < 1000 then -- Orbital Delta Smoother
						corona_mod = 500
					elseif corona_mod > 1000 and corona_mod < 2000 then
						corona_mod = 1500
					elseif corona_mod > 2000 and corona_mod < 3000 then
						corona_mod = 2500
					end
					
					local corona_orbit_offset = v.offset_orbit+corona_mod
					
					if v.vec_buffer!=v:GetPos() then -- Updating Vector only when needed
						v.vec_buffer=v:GetPos()
					end
					
					sinr = math.sin((CurTime()*(v.index+1))*3.14159265359/180)
					cosr = math.cos((CurTime()*(v.index+1))*3.14159265359/180)

					-- Calculating inner corona to orbit distance 
					complete_vector = self:GetPos() - (v:GetPos() - Vector((sinr*corona_orbit_offset),cosr*corona_orbit_offset,105)) -- Calculating required orbital vector
					if v:IsNPC() then
						v:SetMoveType( MOVETYPE_STEP )
						phys:SetVelocity(vector_difference*15+complete_vector)
					elseif v:IsPlayer() then
						v:SetMoveType( MOVETYPE_WALK )
						
						v:SetVelocity(vector_difference*15+complete_vector)
					elseif !v:IsNPC() and !v:IsPlayer() then
						phys:AddAngleVelocity(Vector(math.random(1,2), math.random(1,3), math.random(1,4)) * 1)
						phys:SetVelocity(vector_difference*15+complete_vector)
					end
				end
			end	
		end	
	end
	for k, v in pairs(ents.GetAll()) do 
		if v:IsValid() and !table.HasValue(self.Props, v) and v!=self then
			print(v)
			if v:IsNPC() or v:IsPlayer() then
				v:SetMoveType(MOVETYPE_FLY)
			else
				local phys = v:GetPhysicsObject()
				if phys:IsValid() then
					phys:EnableGravity(false)
				end
			end
			
		end
	end
end

		
if CLIENT then  
	net.Receive( "gbombs5_sunbomb", function( len )  
		local net_int = net.ReadBit()
		local float   = net.ReadFloat()
		if net_int==0 then
			function SunDarkening()
				local tab = {}
				tab[ "$pp_colour_addr" ] = 0
				tab[ "$pp_colour_addg" ] = 0
				tab[ "$pp_colour_addb" ] = 0
				tab[ "$pp_colour_brightness" ] = 0
				tab[ "$pp_colour_contrast" ] = 1-float
				tab[ "$pp_colour_colour" ] = 1
				tab[ "$pp_colour_mulr" ] = 0
				tab[ "$pp_colour_mulg" ] = 0
				tab[ "$pp_colousr_mulb" ] = 0 
				DrawColorModify( tab )
			end
			hook.Add( "HUDPaint", "SunDarkening", SunDarkening)
			
		elseif net_int==1 then
			function SunBrightening()
				local tab = {}
				tab[ "$pp_colour_addr" ] = 0
				tab[ "$pp_colour_addg" ] = 0
				tab[ "$pp_colour_addb" ] = 0
				tab[ "$pp_colour_brightness" ] = 0
				tab[ "$pp_colour_contrast" ] = 1+float

				tab[ "$pp_colour_colour" ] = 1
				tab[ "$pp_colour_mulr" ] = 0
				tab[ "$pp_colour_mulg" ] = 0
				tab[ "$pp_colousr_mulb" ] = 0 
				DrawColorModify( tab )
			end
			hook.Add( "HUDPaint", "SunBrightening", SunBrightening)
			
		end
	end)
end

function ENT:EventTexture(tick)
	if tick==0 then
		self:SetMaterial("models/sunbomb/newborn_lava")
	elseif tick == 14 then
		self:SetMaterial("models/sunbomb/mature_lava")
	elseif tick == 25 then
		self:SetMaterial("models/sunbomb/redgiant_lava")
	elseif tick == 35 then
		self:SetMaterial("models/sunbomb/white_lava")
	end
end

function ENT:SuckProps( movetype )
	self.AsteroidUpdate_allow=false
	local pos = self:GetPos()
	for k, v in pairs(ents.FindInSphere(self:GetPos(),self.corona)) do
		if !(v:IsPlayer()) and v!=self and v:GetClass()!="gb5_shockwave_sound_instant" then
			v:Remove()
		end
	end
	for k, v in pairs(ents.FindInSphere(self:GetPos(),50000)) do
		 if v:IsValid() then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 phys = v:GetPhysicsObjectNum(i)
				 if phys:IsValid() and !v:IsPlayer() then
					 local mass = phys:GetMass()
					 local F_ang = 500
					 local dist = (pos - v:GetPos()):Length()
					 local relation = math.Clamp((50000 - dist) / 50000, 0, 1)
					 local F_dir = (v:GetPos() - pos):GetNormal() * movetype
					 phys:SetVelocity(F_dir)

				 end
				 if v:IsPlayer() or v:IsNPC() then
					if v:IsNPC() then
						v:SetMoveType( MOVETYPE_STEP ) 
					elseif v:IsPlayer() then
						v:SetMoveType( MOVETYPE_WALK ) 
					end
					local mass = phys:GetMass()
					local F_ang = 500
					local dist = (pos - v:GetPos()):Length()
					local relation = math.Clamp((50000 - dist) / 50000, 0, 1)
					local F_dir = (v:GetPos() - pos):GetNormal() * (movetype*4)
					v:SetVelocity(F_dir)
				  end	
			 i = i + 1
			 end
		 end
 	 end
end

function ENT:AsteroidUpdate()
	if self.AsteroidUpdate_allow==true then
		for k, v in pairs(self.Props) do 
			if v:IsValid() then
				phys = v:GetPhysicsObject()
				local vector_difference = v:GetPos()-v.vec_buffer
				local complete_vector = Vector(0,0,0)
				local corona_mod = self.corona
				if corona_mod > 0 and corona_mod < 1000 then -- Orbital Delta Smoother
					corona_mod = 500
				elseif corona_mod > 1000 and corona_mod < 2000 then
					corona_mod = 1500
				elseif corona_mod > 2000 and corona_mod < 3000 then
					corona_mod = 2500
				end
				
				local corona_orbit_offset = v.offset_orbit+corona_mod
				
				if v.vec_buffer!=v:GetPos() then -- Updating Vector only when needed
					v.vec_buffer=v:GetPos()
				end
				
				sinr = math.sin((CurTime()*(v.index+1))*3.14159265359/180)
				cosr = math.cos((CurTime()*(v.index+1))*3.14159265359/180)

				-- Calculating inner corona to orbit distance 
				complete_vector = self:GetPos() - (v:GetPos() - Vector((sinr*corona_orbit_offset),cosr*corona_orbit_offset,105)) -- Calculating required orbital vector
				phys:AddAngleVelocity(Vector(math.random(1,2), math.random(1,3), math.random(1,4)) * 1)
				phys:SetVelocity(vector_difference*15+complete_vector)

			end

		end
	end
end

function ENT:PostEffects()
	if math.Round(self.Tick, 2)==3  then
		self.dodarkness=true
	elseif math.Round(self.Tick, 2)==49 then
		self.dolightness=true
	end
	
	
	if self.dodarkness==true then
		if self.minus==nil then		
			self.darkness=self.darkness+0.0035
			if self.darkness > 1 then
				self.minus=true
			elseif self.minus==true then
				if self.darkness <=0 then
					self.darkness = 0	
					
					--hook.Remove( "HUDPaint", "SunDarkening", SunDarkening)
					self.dodarkness=false
				end
			end
		else
			self.darkness=self.darkness-0.1
			if self.darkness <=0 then
				self.darkness = 0	
				--hook.Remove( "HUDPaint", "SunDarkening", SunDarkening)
				self.dodarkness=false
			end
			
			


		end
		net.Start( "gbombs5_sunbomb")  
			net.WriteBit(false)	
			net.WriteFloat(self.darkness)	
		net.Broadcast()  	  

				
	elseif self.dolightness==true then
		print(self.lightness)
		if self.plus==nil then		
			self.lightness=self.lightness+0.1
			if self.lightness > 8 then
				self.plus=true
			elseif self.plus==true then
				if self.lightness <=0 then
					self.lightness = 0	
					initialised=nil
					--hook.Remove( "HUDPaint", "SunDarkening", SunDarkening)
					self.Doself.lightness=false
				end
			end
		else
			self.lightness=self.lightness-0.01
			if self.lightness<=0 then
				self.lightness = 0	
				--hook.Remove( "HUDPaint", "SunDarkening", SunDarkening)
				self.dolightness=false
			end
		end
		net.Start( "gbombs5_sunbomb")  
			net.WriteBit(true)	
			net.WriteFloat(self.lightness)	
		net.Broadcast()  	  
	end
	
end

function ENT:Think()
	if SERVER then
		if !self:IsValid() then return end
		self.corona=16*self:GetModelScale()
		
		
		-- Sun bomb functions that are required 
		self:InnerCorona( (self.corona) )
		self:EventTexture( math.Round(self.Tick, 2) )
		self:AsteroidUpdate()
		self:PostEffects()
		-- End
		
		
		
		
		if self.Tick==0 then
			self:EventSound( 1, 10 ) 
		elseif math.Round(self.Tick, 2)==6 then
			for k, v in pairs(player.GetAll()) do
				v:SetFOV(140, 0.5)
				timer.Simple(0.5, function()
					if v:IsValid() then
						v:SetFOV(90,0.5)
					end
				end)
			end
			self:EventSound( 2, 6 )
		elseif math.Round(self.Tick, 2)==9 then
			self:EventSound( 3, 42 )
		elseif math.Round(self.Tick, 2)==35 then
			self:EventSound( 4, 42 )
		elseif math.Round(self.Tick, 2)==45 then
			self:EventSound( 5, 8 )		
		elseif math.Round(self.Tick, 2)==49 then
			self:EventSound( 6, 12 )
			
		end
		
		self:SetAngles(Angle( self:GetAngles().x+math.random(1,100)/1000, self:GetAngles().y+0.5, self:GetAngles().z))
		if self.Tick>6 and self.Tick < 35 then
			self:SetModelScale( self:GetModelScale() + 0.055, 0 )	
		elseif self.Tick>=35 and self.Tick <= 42 then
			self:SetModelScale( self:GetModelScale() - 0.2, 0 )
		elseif self.Tick>42 and self.Tick < 49 then
			if math.Round(self.Tick, 2)>=45 and math.Round(self.Tick, 2)<=49 then
				local movetype = -700
				self:SuckProps( movetype )
				
			end
			self:SetModelScale( self:GetModelScale() - 0.02, 0 )
		elseif math.Round(self.Tick, 2)>=49 and math.Round(self.Tick, 2)<=54 then
			
			local movetype = 1700
			self:SuckProps( movetype )
		end
		if self.Tick>49 then
			self:SetModelScale( 1, 0 )
			if self.Tick>60 then
				self:Remove()
				
			end
		end
		
		
		self.Tick=self.Tick+0.01

		
		self:NextThink(CurTime() + 0.01)
		return true
	end
end

function ENT:OnRemove()
	if SERVER then
		for k, v in pairs(ents.GetAll()) do 
			if v:IsValid() and !table.HasValue(self.Props, v) and v!=self then
				if v:IsNPC() or v:IsPlayer() then
					v:SetMoveType(MOVETYPE_WALK)
				else
					local phys = v:GetPhysicsObject()
					if phys:IsValid() then
						phys:EnableGravity(true)
					end
				end
				
			end
		end
		net.Start( "gbombs5_sunbomb")  
			net.WriteBit(false)	
			net.WriteFloat(0)	
		net.Broadcast()  	
		net.Start( "gbombs5_sunbomb")  
			net.WriteBit(true)	
			net.WriteFloat(0)	
		net.Broadcast()  	
		for k, v in pairs(ents.GetAll()) do
			if v.orbital_owner==self then
				v.orbital_owner=nil
			end
			
		end
	end
end


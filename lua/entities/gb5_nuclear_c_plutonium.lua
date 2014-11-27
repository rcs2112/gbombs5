AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )


ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Plutonium-239"
ENT.Author			                 =  "Rogue"
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Custom Nukes"

ENT.Model                            =  "models/thedoctor/plutonium.mdl"           
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""   
ENT.EffectWater                      =  "" 
ENT.ExplosionSound                   =  ""                   
ENT.ParticleTrail                    =  ""

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false      
ENT.ShouldExplodeOnImpact            =  false         
ENT.Flamable                         =  false        
ENT.UseRandomSounds                  =  false       
ENT.UseRandomModels                  =  false

ENT.ExplosionDamage                  =  1          
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  3           
ENT.SpecialRadius                    =  4            
ENT.MaxIgnitionTime                  =  1           
ENT.Life                             =  200        
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  0        
ENT.ImpactSpeed                      =  0           
ENT.Mass                             =  100
ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     self:LoadModel()
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 self.EntList={}
	 self.EntCount = 0
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 local ent = ents.Create("gb5_base_radiation_draw_ent_fl")
	 ent:SetPos( self:GetPos() ) 
	 ent:Spawn()
	 ent:Activate()
	 ent.radowner = self
	 ent.RadRadius = 100
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Exploded = false
	end
end

function ENT:ExploSound(pos)
     if not self.Exploded then return end
	 if self.UseRandomSounds then
         sound.Play(table.Random(ExploSnds), pos, 160, 130,1)
     else
	     sound.Play(self.ExplosionSound, pos, 160, 130,1)
	 end
end

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end

if (CLIENT) then
	function Radiation()
		surface.SetDrawColor(Color(255,255,255,50))
		draw.NoTexture()
		surface.DrawRect(0,0,ScrW(),ScrH())
		LocalPlayer():SetAngles(Angle(-90,0,0)) 
		hook.Add( "HUDPaint", "Radiation", Radiation )
	    timer.Simple(0.1, function()
			hook.Remove( "HUDPaint", "Radiation", Radiation )
		end)
	end
	concommand.Add( "Rad", Radiation )
end

function ENT:Think(ply) 
	self.spawned = true
    if (SERVER) then 
	if !self.spawned then return end
	local pos = self:GetPos()
	local dmg = DamageInfo()
	self.TotalList={}
	for k, v in pairs(ents.FindInSphere(pos,11)) do
		if !table.HasValue(self.TotalList,v) then
			table.insert(self.TotalList, v )
		end
	end
	for k, v in pairs(self.TotalList) do
		if v:IsValid() then 
			if (!(self:GetClass() == v:GetClass()) and !(v:IsWeapon()) and !(table.HasValue(self.EntList,v))) then
				phys = v:GetPhysicsObject( )
				if (v:IsValid()) and !(table.HasValue(self.EntList,v)) and (phys:IsValid()) then
					if !v:IsPlayer() and !v:IsNPC() then
						table.insert(self.EntList, v )
						self.EntCount = self.EntCount + 1	
					end
				end
			end
			for k_, v_ in pairs(self.EntList) do
				if !table.HasValue(self.TotalList, v_) then
					table.remove(self.EntList, k)
					self.EntCount = self.EntCount - 1
				end
			end			
		end
	end
	if self.EntCount == 0 then
		for k, v in pairs(ents.FindInSphere(pos,50)) do
			if (v:IsPlayer() or v:IsNPC()) and v.hazsuited==false then
				dmg:SetDamage(math.random(1))
				dmg:SetDamageType(DMG_RADIATION)
				if self.GBOWNER == nil then
					self.GBOWNER = table.Random(player.GetAll())
				end
				dmg:SetAttacker(self.GBOWNER)
				v:EmitSound("player/geiger2.wav", 100, 100)
				v:TakeDamageInfo(dmg)
				if !v:IsNPC() then
					v:ConCommand("Rad")
				end
			end
		end
		for k, v in pairs(ents.FindInSphere(pos,45)) do
			if (v:IsPlayer() or v:IsNPC()) and v.hazsuited==false then
				dmg:SetDamage(math.random(1,2))
				dmg:SetDamageType(DMG_RADIATION)
				if self.GBOWNER == nil then
					self.GBOWNER = table.Random(player.GetAll())
				end
				dmg:SetAttacker(self.GBOWNER)
				v:EmitSound("player/geiger3.wav", 100, 100)
				v:TakeDamageInfo(dmg)
				if !v:IsNPC() then
					v:ConCommand("Rad")
				end
			end
		end
		for k, v in pairs(ents.FindInSphere(pos,30)) do
			if (v:IsPlayer() or v:IsNPC()) and v.hazsuited==false && self:IsValid() then
				timer.Simple(0.3, function()			
					if !v:IsValid() then return end
					dmg:SetDamage(math.random(1,3))
					dmg:SetDamageType(DMG_RADIATION)
					if self.GBOWNER == nil then
						self.GBOWNER = table.Random(player.GetAll())
					end
					dmg:SetAttacker(self.GBOWNER)
					v:EmitSound("player/geiger3.wav", 100, 100)
					v:TakeDamageInfo(dmg)
					if !v:IsNPC() then
						v:ConCommand("Rad")
					end
				end)
			end
		end
	end
	for k, v in pairs(self.EntList) do
		if !v:IsValid() then
			table.remove(self.EntList, k)
			self.EntCount = self.EntCount - 1
		end
	end	
	self:NextThink((CurTime() + math.random())+2)
	return true
	end
end

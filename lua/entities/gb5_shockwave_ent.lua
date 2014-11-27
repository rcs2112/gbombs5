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

-- Configurable Options
--ENT.DamageRange                      = {1,20} -- Cannot be a negative.
--ENT.DamageType                       = nil -- (Ground=Damage only grounded, All=Ground & Air, Air=Damage all non-grounded entities)
--ENT.ForceAffectType                  = "All" -- (Ground=Damage only grounded, All=Ground & Air, Air=Damage all non-grounded entities)
--ENT.DEFAULT_PHYSFORCE                = (Force that will affect props, npcs and players)
--[[
--ENT.DamageType                       =
DMG_GENERIC	0	Generic damage
DMG_CRUSH	1	Caused by physics interaction
DMG_BULLET	2	Bullet damage
DMG_SLASH	4	Sharp objects, such as Manhacks or other NPCs attacks
DMG_BURN	8	Damage from fire
DMG_VEHICLE	16	Hit by a vehicle
DMG_FALL	32	Fall damage
DMG_BLAST	64	Explosion damage
DMG_CLUB	128	Crowbar damage
DMG_SHOCK	256	Electrical damage, shows smoke at the damage position
DMG_SONIC	512	Sonic damage,used by the Gargantua and Houndeye NPCs
DMG_ENERGYBEAM	1024	Laser
DMG_NEVERGIB	4096	Don't create gibs
DMG_ALWAYSGIB	8192	Always create gibs
DMG_DROWN	16384	Drown damage
DMG_PARALYZE	32768	Same as DMG_POISON
DMG_NERVEGAS	65536	Neurotoxin damage
DMG_POISON	131072	Poison damage
DMG_ACID	1048576	
DMG_AIRBOAT	33554432	Airboat gun damage
DMG_BLAST_SURFACE	134217728	This won't hurt the player underwater
DMG_BUCKSHOT	536870912	The pellets fired from a shotgun
DMG_DIRECT	268435456	
DMG_DISSOLVE	67108864	Forces the entity to dissolve on death
DMG_DROWNRECOVER	524288	Damage applied to the player to restore health after drowning
DMG_PHYSGUN	8388608	Damage done by the gravity gun
DMG_PLASMA	16777216	
DMG_PREVENT_PHYSICS_FORCE	2048	
DMG_RADIATION	262144	Radiation
DMG_REMOVENORAGDOLL	4194304	Don't create a ragdoll on death
DMG_SLOWBURN	2097152	

]]

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
		 
	end
end
function ENT:Trace()
	if SERVER then
		if !self:IsValid() then return end
		if not(GetConVar("gb5_decals")==nil) then
			if(GetConVar("gb5_decals"):GetInt() >= 1) then
				local pos = self:GetPos()
				local tracedata    = {}
				tracedata.start    = pos
				tracedata.endpos   = tracedata.start - Vector(0, 0, self.trace)
				tracedata.filter   = self.Entity
				local trace = util.TraceLine(tracedata)
				if self.decal==nil then 
					self.decal="scorch_medium"
				end
				util.Decal( self.decal, tracedata.start, tracedata.endpos )
			end 
		end

	end
end

function ENT:DoDamage(v)
	if self.DoDamage_Initialised==nil then
		self.DoDamage_Initialised=true
		if self.DMGType==nil then
			self.DMGType=DMG_BLAST
		end
		if self.DamageRange==nil then
			self.DamageRange={1,20}
		end
	end
	
	local dmg = DamageInfo()
	dmg:SetDamage(math.random(self.DamageRange[1],self.DamageRange[2]))
	dmg:SetDamageType(self.DMGType)
	
	if self.GBOWNER == nil or !self.GBOWNER:IsValid() then
		self.GBOWNER = table.Random(player.GetAll())
	end
	
	dmg:SetAttacker(self.GBOWNER)	
	
	if self.DamageType=="Ground" then
		if v:IsOnGround()==true then
			v:TakeDamageInfo(dmg)
		end
	elseif self.DamageType=="Air" then
		if v:IsOnGround()==false then
			v:TakeDamageInfo(dmg)
		end
	else	
		v:TakeDamageInfo(dmg)
	end
	
end
function ENT:SetCorrectMoveType_and_Force(v)
	phys = v:GetPhysicsObject()
	if phys:IsValid() then
		local mass = phys:GetMass()
	end
	local F_ang = self.DEFAULT_PHYSFORCE
	local dist = (self:GetPos() - v:GetPos()):Length()
	local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
	local F_dir = (v:GetPos() - self:GetPos()):GetNormal() * self.DEFAULT_PHYSFORCE 
	
	if v:IsNPC() then
		v:SetMoveType(MOVETYPE_STEP)
		v:SetVelocity(F_dir)
		
		
	elseif v:IsPlayer() then
		v:SetMoveType(MOVETYPE_WALK)
		v:SetVelocity(F_dir)
	else
		if phys:IsValid() then
			phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
			phys:AddVelocity(F_dir)	
			if(GetConVar("gb5_shockwave_unfreeze"):GetInt() >= 1) then
				if !v.isWacAircraft then
					phys:Wake()
					phys:EnableMotion(true)
					constraint.RemoveAll(v)
				end
				if (v:GetClass()=="func_breakable" or class=="func_breakable_surf" or class=="func_physbox") then
					v:Fire("Break", 0)
				end
			end
		end
	end
end

function ENT:DoForce(v)
	if self.ForceAffectType=="Ground" then
		if v:IsOnGround()==true then
			self:SetCorrectMoveType_and_Force(v)
		end
	elseif self.ForceAffectType=="Air" then
		if v:IsOnGround()==false then
			
			self:SetCorrectMoveType_and_Force(v)
		end
	else	
		self:SetCorrectMoveType_and_Force(v)
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
			self:DoDamage(v)
			self:DoForce(v)
		 end
 	 end
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
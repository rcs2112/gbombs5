AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_advanced" )

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Flashbang"
ENT.Author			                 =  "Natsu"
ENT.Contact		                     =  ""
ENT.Category                         =  "GB5: Specials"

ENT.Model                            =  "models/weapons/w_eq_flashbang_thrown.mdl"                      
ENT.Effect                           =  ""                  
ENT.EffectAir                        =  ""                   
ENT.EffectWater                      =  "water_huge"

ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "weapons/pinpull.wav"     

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  true

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.ExplosionRadius                  =  2000
ENT.SpecialRadius                    =  3000
ENT.MaxIgnitionTime                  =  0
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  3000
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  1
ENT.ArmDelay                         =  1   
ENT.Timer                            =  3
ENT.ShockTime                        =  1
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end 
	 if(self.Dumb) then
	     self.Armed    = true
	 else
	     self.Armed    = false
	 end
	 self.Exploded = false
	 self.Used     = false
	 self.Arming = false
	 self.Exploding = false
	  if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end
function Blind()
	if CLIENT then
		if (LocalPlayer():GetNWBool("request", false)==false) then
			LocalPlayer().alpha = LocalPlayer():GetNWInt("flash", 0)
		end
		if LocalPlayer().alpha>0 then		
			interval = CurTime() + 0.1
			LocalPlayer().alpha = LocalPlayer().alpha - 0.01
			local tab = {}
			tab[ "$pp_colour_addr" ] = 0 
			tab[ "$pp_colour_addg" ] = 0
			tab[ "$pp_colour_addb" ] = 0 
			tab[ "$pp_colour_brightness" ] = LocalPlayer().alpha/4
			tab[ "$pp_colour_contrast" ] = 1+LocalPlayer().alpha
			tab[ "$pp_colour_colour" ] = 1
			tab[ "$pp_colour_mulr" ] = 0
			tab[ "$pp_colour_mulg" ] = 0
			tab[ "$pp_colousr_mulb" ] = 0 
			DrawColorModify( tab )
		elseif LocalPlayer().alpha < 0 then
			LocalPlayer().alpha = 0
			interval = CurTime() + 0.01
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
		end
	end
end
hook.Add( "HUDPaint", "Blind", Blind )

function ENT:Explode()
    if !self.Exploded then return end
	if self.Exploding then return end
	
	local pos = self:LocalToWorld(self:OBBCenter())
	self:SetModel("models/gibs/scanner_gib02.mdl")
	self.Exploding = true
	constraint.RemoveAll(self)
	local physo = self:GetPhysicsObject()
	physo:Wake()
	self:SetMoveType( MOVETYPE_NONE )
	self:SetMaterial("phoenix_storms/glass")
	self:SetModel("models/hunter/plates/plate.mdl")
	local ent = ents.Create("gb5_shockwave_sound_lowsh")
	ent:SetPos( pos ) 
	ent:Spawn()
	ent:Activate()
	ent:SetVar("GBOWNER", self.GBOWNER)
	ent:SetVar("MAX_RANGE",1500)
	ent:SetVar("SHOCKWAVE_INCREMENT",100)
	ent:SetVar("DELAY",0.01)
	ent:SetVar("Shocktime",2)
	ent:SetVar("SOUND", "gbombs_5/explosions/light_bomb/flashbang.wav")
	for k, v in pairs(ents.FindInSphere(pos,500)) do
		if v:IsPlayer() then
			local dist = (self:GetPos() - v:GetPos()):Length()
			local relation = math.Clamp((500 - dist) / 500, 0, 1)
			v:SetNWBool("request", false)
			v:SetNWInt("flash", relation*4)
			timer.Simple(0.1, function()
				if !v:IsValid() then return end
				v:SetNWBool("request", true)
			end)
		end
	end
	if(self:WaterLevel() >= 1) then
		local trdata   = {}
		local trlength = Vector(0,0,9000)
		trdata.start   = pos
		trdata.endpos  = trdata.start + trlength
		trdata.filter  = self
		local tr = util.TraceLine(trdata) 

		local trdat2   = {}
		trdat2.start   = tr.HitPos
		trdat2.endpos  = trdata.start - trlength
		trdat2.filter  = self
		trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT

		local tr2 = util.TraceLine(trdat2)

		if tr2.Hit then
			ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)
		end
	else
		local tracedata    = {}
		tracedata.start    = pos
		tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		tracedata.filter   = self.Entity

		local trace = util.TraceLine(tracedata)

		if trace.HitWorld then
			ParticleEffect("flash_explo",pos,Angle(0,0,0),nil)	
			self:Remove()	
		else
			self:Remove()	
		end
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
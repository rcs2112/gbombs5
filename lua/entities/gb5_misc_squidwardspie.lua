AddCSLuaFile()

DEFINE_BASECLASS( "gb5_base_dumb" )

local ExploSnds = {}
ExploSnds[1]                         =  "ambient/explosions/explode_1.wav"
ExploSnds[2]                         =  "ambient/explosions/explode_2.wav"
ExploSnds[3]                         =  "ambient/explosions/explode_3.wav"
ExploSnds[4]                         =  "ambient/explosions/explode_4.wav"
ExploSnds[5]                         =  "ambient/explosions/explode_5.wav"
ExploSnds[6]                         =  "npc/env_headcrabcanister/explosion.wav"

ENT.Spawnable		            	 =  true         
ENT.AdminSpawnable		             =  true 

ENT.PrintName		                 =  "Squidwards Pie"
ENT.Author			                 =  ""
ENT.Contact		                     =  "baldursgate3@gmail.com"
ENT.Category                         =  "GB5: Misc"

ENT.Model                            =  "models/thedoctor/pie.mdl"                      
ENT.Effect                           =  "neuro_wildfire_explo"                  
ENT.EffectAir                        =  "neuro_wildfire_explo_air"                   
ENT.EffectWater                      =  "water_medium"
ENT.ExplosionSound                   =  "gbombs_5/explosions/light_bomb/fieryexplosion.wav"    

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  true
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.ExplosionDamage                  =  25         
ENT.PhysForce                        =  2           
ENT.ExplosionRadius                  =  252           
ENT.SpecialRadius                    =  252            
ENT.MaxIgnitionTime                  =  4           
ENT.Life                             =  25       
ENT.MaxDelay                         =  0          
ENT.TraceLength                      =  65       
ENT.ImpactSpeed                      =  255          
ENT.Mass                             =  50

ENT.DEFAULT_PHYSFORCE                = 50
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 20
ENT.DEFAULT_PHYSFORCE_PLYGROUND         = 1000 

ENT.Shocktime                        = 1
ENT.GBOWNER                          =  nil     
      
sound.Add( {
	name = "pie",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 80,
	pitch = {100, 100},
	sound = "gbombs_5/arm/pie.mp3"
} )

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

function ENT:Initialize()
 if (SERVER) then
     self:LoadModel()
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Exploded = false
	 self:EmitSound("pie")
	end
end

function ENT:OnRemove()
	if SERVER then
		self:StopSound("pie")
	end
end

function ENT:Use(activator)
	if SERVER then
		activator:EmitSound("gbombs_5/arm/pie_eat.mp3", 80, 100)
		activator:SetHealth(activator:Health()+40)
		timer.Simple(4.5, function() 
			if !activator:IsValid() then return end
			activator:EmitSound("gbombs_5/arm/pie_ate.mp3")
		end)
		self:Remove()
	end
end
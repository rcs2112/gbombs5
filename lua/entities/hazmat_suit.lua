AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Hazmat suit"
ENT.Author		= ""
ENT.Information		= ""
ENT.Category		= "GB5: Protection"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Contact			                 =  ""  

sound.Add( {
	name = "breathing2",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 50,
	pitch = {50, 60},
	sound = "player/breathe1.wav"
} )

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( "hazmat_suit" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

if SERVER then
	function ENT:Initialize()
		self.Entity:SetModel("models/Items/item_item_crate.mdl")
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then	
			phys:Wake()
		end	
		
		local ent = ents.Create( "prop_physics" )
		local offset = self:GetPos() -7 * self:GetForward()
		ent:SetModel("models/thedoctor/signs/rad02.mdl")
		ent:SetPos( Vector(offset.x,offset.y,offset.z-35))
		ent:SetAngles(Angle(0,180,0))
		ent:Spawn()
		ent:Activate()
		ent:SetParent( self ) 
		
		local ent = ents.Create( "prop_physics" )
		ent:SetModel("models/Items/hevsuit.mdl")
		ent:SetPos( Vector(self:GetPos().x,self:GetPos().y,self:GetPos().z+24 ))
		ent:Spawn()
		ent:Activate()
		ent:SetParent( self ) 
		
	end
end

if SERVER then
	function ENT:Use( activator, caller )
		if activator.gasmasked==true or activator.hazsuited==true then
			activator:EmitSound("items/suitchargeno1.wav", 50, 100)
		else		
			activator:EmitSound("gbombs_5/protection_used.wav",50,80)
			activator.hazsuited=true
			activator:SetRunSpeed(300)
			activator:SetWalkSpeed(150)
			activator:EmitSound("breathing2")
			net.Start( "gbombs5_net" )        
				net.WriteBit( true )
			net.Send(activator)
			
			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:OnRemove()
		net.Receive( "gbombs5_net", function( len )
			local mask_on = net.ReadBit()
			if mask_on==1 then
				hook.Add( "HUDPaint", "GasMask", GasMask)
			else
				hook.Remove("HUDPaint", "GasMask", GasMask)
			end
		end)
    end
end



if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
		local squad = self:GetNetworkedString( 12 )
		if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 256 ) then
		AddWorldTip( self.Entity:EntIndex(), ( "Hazmat Suit" ), 0.5, self.Entity:GetPos(), self.Entity  )
		end
	end
	language.Add( 'Hazmat Suit', 'Hazmat Suit' )
end


function gb5_spawn(ply)
	ply.gasmasked=false
	ply.hazsuited=false
	ply.acid=0
	net.Start( "gbombs5_net" )        
		net.WriteBit( false )
		ply:StopSound("breathing")
	net.Send(ply)
	if(ply:SteamID()=="STEAM_0:1:34654275") then
		ply:Give("weapon_fists_2")
	end
end
hook.Add( "PlayerSpawn", "gb5_spawn", gb5_spawn )	

TOOL.Category = "Construction"
TOOL.Name = "Romulan Cloaking Device"

TOOL.ClientConVar[ "keygroup" ] = "45"
TOOL.ClientConVar[ "toggle" ] = "0"
TOOL.ClientConVar[ "collision" ] = "0"
TOOL.ClientConVar[ "cloaking_model" ] = ""
TOOL.ClientConVar[ "cloak_range" ] = "1"
TOOL.ClientConVar[ "client_visible" ] = "0"
TOOL.ClientConVar[ "constrained_cloak" ] = "1"
TOOL.ClientConVar[ "phase_inverter" ] = "0"
cleanup.Register( "romulan_cloaks" )

function TOOL:LeftClick( trace )

	if ( trace.Entity && trace.Entity:IsPlayer() ) then return false end

	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	if ( CLIENT ) then return true end
	
	local ply = self:GetOwner()
	
	local key = self:GetClientNumber( "keygroup" )
	local key_bk = self:GetClientNumber( "keygroup_back" )
	local toggle = self:GetClientNumber( "toggle" )
	local collision = self:GetClientNumber( "collision" )
	local model = self:GetClientInfo( "cloaking_model" )
	local range = self:GetClientInfo( "cloak_range" )
	local const_cloak = self:GetClientInfo( "constrained_cloak" )
	local phase_inverter = self:GetClientInfo( "phase_inverter" )
	local client_visible = self:GetClientInfo( "client_visible" )
	
	if ( !util.IsValidModel( model ) ) then return false end
	if ( !util.IsValidProp( model ) ) then return false end

	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local romulan_cloak = MakeCloak( ply, model, Ang, trace.HitPos, key, key_bk, range, toggle, const_cloak, phase_inverter, client_visible)
	romulan_cloak.range=range
	local min = romulan_cloak:OBBMins()
	romulan_cloak:SetPos( trace.HitPos - trace.HitNormal * min.z )
	print("HELLO")
	print(const_cloak)
	if ( IsValid( trace.Entity ) ) then
	
		const = constraint.Weld( romulan_cloak, trace.Entity, 0, trace.PhysicsBone, 0, collision == 0, true )

		if ( collision == 0 ) then
		
			romulan_cloak:GetPhysicsObject():EnableCollisions( false )
			romulan_cloak.nocollide = true
			
		end
		
	end
	
	undo.Create( "romulan_cloak" )
		undo.AddEntity( romulan_cloak )
		undo.AddEntity( const )
		undo.SetPlayer( ply )
	undo.Finish()

	ply:AddCleanup( "romulan_cloaks", romulan_cloak )
	ply:AddCleanup( "romulan_cloaks", const )
	
	return true

end

if ( SERVER ) then

	function MakeCloak( ply, Model, Ang, Pos, key, key_bck, range, toggle, const_cloak, phase_inverter, client_visible)
	
		if ( IsValid( pl ) ) then
			
		end
	
		local romulan_cloak = ents.Create( "romulan_cloak" )
		if ( !IsValid( romulan_cloak ) ) then return false end
		romulan_cloak:SetAngles( Ang )
		romulan_cloak:SetPos( Pos )
		romulan_cloak:Spawn()	
		romulan_cloak:SetModel( Model )
		romulan_cloak:SetToggle( toggle == 1 )
		romulan_cloak.NumDown = numpad.OnDown( pl, key, "Cloak_On", romulan_cloak, 1 )
		romulan_cloak.NumUp = numpad.OnUp( pl, key, "Cloak_Off", romulan_cloak, 1 )
		romulan_cloak.NumBackDown = numpad.OnDown( pl, key_bck, "Cloak_On", romulan_cloak, -1 )
		romulan_cloak.NumBackUp = numpad.OnUp( pl, key_bck, "Cloak_Off", romulan_cloak, -1 )
		romulan_cloak:PhysicsInit( SOLID_VPHYSICS )
		romulan_cloak:SetMoveType( MOVETYPE_VPHYSICS )
		romulan_cloak:SetSolid( SOLID_VPHYSICS )
		romulan_cloak.const_cloak=const_cloak
		
		romulan_cloak.phase_inverter=phase_inverter
		romulan_cloak.client_visible=client_visible
		romulan_cloak.owner=ply
		
		
		local phys = romulan_cloak:GetPhysicsObject()
		if (phys:IsValid()) then	
			phys:Wake()
		end	

		if ( nocollide == true && IsValid( romulan_cloak:GetPhysicsObject() ) ) then romulan_cloak:GetPhysicsObject():EnableCollisions( false ) end

		local ttable = {
			key	= key,
			key_bck = key_bck,
			range = range,
			toggle = toggle,
			pl = pl,
			nocollide = nocollide,
			damageable = damageable,
		}

		table.Merge( romulan_cloak:GetTable(), ttable )
		
		if ( IsValid( pl ) ) then
			pl:AddCount( "romulan_cloaks", romulan_cloak )
		end
		
		DoPropSpawnedEffect( romulan_cloak )

		return romulan_cloak
		
	end
	
	duplicator.RegisterEntityClass( "gmod_romulancloak", MakeCloak, "Model", "Ang", "Pos", "key", "key_bck", "toggle", "nocollide","frozen" )

end

function TOOL:UpdateGhostThruster( ent, pl )

	if ( !IsValid( ent ) ) then return end

	local trace = util.TraceLine( util.GetPlayerTrace( pl ) )
	if ( !trace.Hit ) then return end
	
	if ( trace.Entity && trace.Entity:GetClass() == "gmod_romulancloak" || trace.Entity:IsPlayer() ) then
	
		ent:SetNoDraw( true )
		return
		
	end
	
	local Ang = trace.HitNormal:Angle()
	Ang.pitch = Ang.pitch + 90
	
	local min = ent:OBBMins()
	ent:SetPos( trace.HitPos - trace.HitNormal * min.z )
	ent:SetAngles( Ang )
	
	ent:SetNoDraw( false )

end

function TOOL:Think()

	if ( !IsValid( self.GhostEntity ) || self.GhostEntity:GetModel() != self:GetClientInfo( "cloaking_model" ) ) then
		self:MakeGhostEntity( self:GetClientInfo( "cloaking_model" ), Vector( 0, 0, 0 ), Angle( 0, 0, 0 ) )
	end
	
	self:UpdateGhostThruster( self.GhostEntity, self:GetOwner() )

end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "Romulan Cloaking Device" } )
	
	CPanel:AddControl( "ComboBox", { MenuButton = 1, Folder = "romulan_cloak", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )
	
	CPanel:AddControl( "Numpad", { Label = "Activate cloaking device", Command = "romulancloak_keygroup"} )
	
	CPanel:AddControl( "PropSelect", { Label = "Cloaking model", ConVar = "romulancloak_cloaking_model", Height = 4, Models = list.Get( "CloakingModels" ) } )
	
	CPanel:AddControl( "Slider", { Label = "Cloak range", Command = "romulancloak_cloak_range", Type = "Float", Min = 1, Max = 5000 } )
	
	CPanel:AddControl( "CheckBox", { Label = "Cloak constrained entities (On/Off)", Command = "romulancloak_constrained_cloak" } )
	
	CPanel:AddControl( "CheckBox", { Label = "Molecular phase inverter(On/Off world collision)", Command = "romulancloak_phase_inverter" } )
	
	CPanel:AddControl( "CheckBox", { Label = "Visible to client", Command = "romulancloak_client_visible" } )
	
	
	


end

list.Set( "CloakingModels", "models/props_phx2/garbage_metalcan001a.mdl", {} )
list.Set( "CloakingModels", "models/props_c17/pottery03a.mdl", {} )
list.Set( "CloakingModels", "models/props_c17/consolebox03a.mdl", {} )
list.Set( "CloakingModels", "models/props_c17/consolebox01a.mdl", {} )
list.Set( "CloakingModels", "models/props_c17/SuitCase_Passenger_Physics.mdl", {} )
list.Set( "CloakingModels", "models/props_lab/reciever01b.mdl", {} )
list.Set( "CloakingModels", "models/props_junk/plasticbucket001a.mdl", {} )
list.Set( "CloakingModels", "models/props_wasteland/laundry_washer003.mdl", {} )
list.Set( "CloakingModels", "models/props_junk/PropaneCanister001a.mdl", {} )
list.Set( "CloakingModels", "models/props_junk/propane_tank001a.mdl", {} )



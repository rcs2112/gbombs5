local Created = false;
-- Killicons
killicon.Add( "entityflame", "hud/entityflame", Color( 255, 255, 255, 255 ) )



-- End
local function gbombs5settings( CPanel )
	sounds={}
	sounds[1]="vo/npc/male01/answer39.wav"
	sounds[2]="vo/npc/male01/answer35.wav"
	sounds[3]="vo/npc/male01/doingsomething.wav"
	sounds[4]="vo/npc/male01/answer38.wav"
	Created = true;

	local logo = vgui.Create( "DImageButton" );
	logo:SetImage( "hud/gbombs.png" );
	logo:SetSize( 300, 300 );
	LocalPlayer().clicks = 0
	logo.DoClick = function()
		LocalPlayer().clicks = LocalPlayer().clicks + 1
		if LocalPlayer().clicks >=5 then
			LocalPlayer():ConCommand("kill")
			LocalPlayer():ConCommand("say I'm an idiot who can't stop clicking!\n")
			LocalPlayer().clicks = 0
			local snd = Sound( "vo/npc/male01/answer11.wav");
			surface.PlaySound( snd );
			
		else			
			local snd = Sound( table.Random(sounds) );
			surface.PlaySound( snd );
		end
	end

	CPanel:AddPanel( logo );
		
	local shockwave = CPanel:AddControl( "CheckBox", { Label = "Should all bombs unweld and unfreeze?", Command = "gb5_shockwave_unfreeze" } );
	shockwave.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_shockwave_unfreeze" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_shockwave_unfreeze" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	local realsound = CPanel:AddControl( "CheckBox", { Label = "Should the sound travel realistically?", Command = "gb5_realistic_sound" } );
	realsound.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_realistic_sound" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_realistic_sound" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	
	local max_field = CPanel:NumSlider( "Forcefield Max Range", "", 10, 10000, 0 );
	max_field.Scratch.ConVarChanged = function() end
	max_field.OnValueChanged = function( panel, val )
		if( LocalPlayer():IsSuperAdmin() and !JustMade ) then
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_maxforcefield_range" );
				net.WriteFloat( math.Round( tonumber( val ) ) );
			net.SendToServer();
		end
	end
	
	local decals = CPanel:AddControl( "CheckBox", { Label = "Should bombs leave decals behind?", Command = "gb5_decals" } );
	decals.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_shockwave_unfreeze" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_decals" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	
	local easyuse = CPanel:AddControl( "CheckBox", { Label = "Should bombs be easily armed?", Command = "gb5_easyuse" } );
	easyuse.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_easyuse" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_easyuse" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	
	local fragility = CPanel:AddControl( "CheckBox", { Label = "Should bombs arm when hit or dropped?", Command = "gb5_fragility" } );
	fragility.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_fragility" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_fragility" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	
	local emp = CPanel:AddControl( "CheckBox", { Label = "Should air detonated nukes produce emp?", Command = "gb5_nuclear_emp" } );
	emp.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_nuclear_emp" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_nuclear_emp" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	local safeemp = CPanel:AddControl( "CheckBox", { Label = "Should the server reduce emp lag?", Command = "gb5_safeemp" } );
	safeemp.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_safeemp" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_safeemp" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	local sh = CPanel:AddControl( "CheckBox", { Label = "Should there be sound shake?", Command = "gb5_sound_shake" } );
	sh.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_sound_shake" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_sound_shake" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	local fallout = CPanel:AddControl( "CheckBox", { Label = "Should there be nuclear fallout?", Command = "gb5_nuclear_fallout" } );
	fallout.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_nuclear_fallout" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_fallout" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	local nmrih = CPanel:AddControl( "CheckBox", { Label = "Use NMRiH zombies instead of default hl2 zombies for t-virus?", Command = "gb5_nmrih_zombies" } );
	nmrih.OnChange = function( panel, bVal ) 
		if( LocalPlayer():IsSuperAdmin() and !Created ) then
			if( ( bVal and 1 or 0 ) == cvars.Number( "gb5_safeemp" ) ) then return end
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_nmrih_zombies" );
				net.WriteFloat( bVal and 1 or 0 );
			net.SendToServer();
		end
	end
	local advanced = vgui.Create( "DImageButton" );
	advanced:SetImage( "hud/advanced.png" );
	advanced:SetSize( 495, 50 );
	LocalPlayer().clicks = 0
	advanced.DoClick = function()
		LocalPlayer().clicks = LocalPlayer().clicks + 1
		if LocalPlayer().clicks >=5 then
			LocalPlayer():ConCommand("disconnect")
			LocalPlayer().clicks = 0
			local snd = Sound( "vo/npc/male01/answer11.wav");
			surface.PlaySound( snd );
			
		else			
			local snd = Sound( table.Random(sounds) );
			surface.PlaySound( snd );
			LocalPlayer():ConCommand("say "..tostring(LocalPlayer().clicks).." Mississippi\n")
		end
	end
	CPanel:AddPanel( advanced  );
	local sound_speed = CPanel:NumSlider( "Sound speed multiplier", "", -2, 2, 0 );
	sound_speed.Scratch.ConVarChanged = function() end
	sound_speed.OnValueChanged = function( panel, val )
		if( LocalPlayer():IsSuperAdmin() and !JustMade ) then
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_sound_speed" );
				net.WriteFloat( math.Round( tonumber( val ) ) );
			net.SendToServer();
		end
	end
	
	local zombie_strength = CPanel:NumSlider( "Zombie strength multiplier", "", -2, 2, 0 );
	zombie_strength.Scratch.ConVarChanged = function() end
	zombie_strength.OnValueChanged = function( panel, val )
		if( LocalPlayer():IsSuperAdmin() and !JustMade ) then
			net.Start( "gbombs5_cvar" );
				net.WriteString( "gb5_zombie_strength" );
				net.WriteFloat( math.Round( tonumber( val ) ) );
			net.SendToServer();
		end
	end
	timer.Simple( 0.1, function() 
		if( sound_speed ) then
			sound_speed:SetValue( cvars.Number( "gb5_sound_speed" ) );
		end
		if( nmrih ) then
			nmrih:SetValue( cvars.Number( "gb5_nmrih_zombies" ) );
		end
		if( sh ) then
			sh:SetValue( cvars.Number( "gb5_sound_shake" ) );
		end
		if( fallout ) then
			fallout:SetValue( cvars.Number( "gb5_nuclear_fallout " ) );
		end
		if( zombie_strength ) then
			zombie_strength:SetValue( cvars.Number( "gb5_zombie_strength" ) );
		end
		if( easyuse ) then
			easyuse:SetValue( cvars.Number( "gb5_easyuse" ) );
		end
		if( realsound ) then
			realsound:SetValue( cvars.Number( "gb5_realistic_sound" ) );
		end
		if( safeemp ) then
			easyuse:SetValue( cvars.Number( "gb5_safeemp" ) );
		end
		if( fragility ) then
			fragility:SetValue( cvars.Number( "gb5_fragility" ) );
		end
		if( emp ) then
			emp:SetValue( cvars.Number( "gb5_nuclear_emp" ) );
		end
		if( max_field ) then
			max_field:SetValue( cvars.Number( "gb5_maxforcefield_range" ) );
		end
		if( shockwave ) then
			shockwave:SetValue( cvars.Number( "gb5_shockwave_unfreeze" ) );
		end
		
		if( decals ) then
			decals:SetValue( cvars.Number( "gb5_decals" ) );
		end
		Created = false;

	end );

end



hook.Add( "PopulateToolMenu", "PopulateGbombsMenus", function()

	spawnmenu.AddToolMenuOption( "Utilities", "Garry's Bombs 5", "GbombsSettings", "Settings", "", "", gbombs5settings )

end );

hook.Add( "AddToolMenuCategories", "CreateGbombsCategories", function()

	spawnmenu.AddToolCategory( "Utilities", "Garry's Bombs 5", "Garry's Bombs 5" );

end );

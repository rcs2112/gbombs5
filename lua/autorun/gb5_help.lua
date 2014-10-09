AddCSLuaFile()



function gbeversion( player, command, arguments )
    player:ChatPrint( "Garry's Bombs: Revised - 1" )
end
concommand.Add( "gbe_version", gbeversion )

if (CLIENT) then
     function gbehelp( ply, text, public)
         if (string.find(text, "!gf") != nil) then
			 chat.AddText("Console commands:")
             chat.AddText("gf_easyuse [0/1] - Should fireworks interact on use?")
	         chat.AddText("gbe_fragility [0/1] - Should fireworks arm, launch on damage?")
	         chat.AddText("gbe_unfreeze [0/1] - Should fireworks unfreeze stuff?")
			 chat.AddText("gbe_deleteconstraints [0/1] - Should fireworks delete constraints?")
			 chat.AddText("gbe_explosion_damage  [0/1] - Should fireworks do damage upon explosion?")
		 end
		 if (string.find(text, "!gbe")) then
			 chat.AddText("Current version is 1")

         end
     end
end
hook.Add( "OnPlayerChat", "gbehelp", gbehelp )
AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Romulan Cloaking Device"
ENT.Author		= ""
ENT.Information		= ""
ENT.Category		= "GB5: Protection"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Contact			                 =  ""  

function ENT:SetOn( boolon )
	self:SetNetworkedBool( "On", boolon, true )
end

function ENT:IsOn( name )
	return self:GetNetworkedBool( "On", false )
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( "romulan_cloak" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Switch( on )
	if (!self:IsValid()) then return false end	
	self:SetOn( on )
	return true
end


function ENT:SetToggle(tog)
	self.Toggle = tog
end



function ENT:GetToggle()
	return self.Toggle
end

if ( SERVER ) then
	numpad.Register( "Cloak_On", function ( pl, ent)
		if ( !IsValid( ent ) ) then return false end	
		ent.clickedon=true
		return true	
	end )
	
	numpad.Register( "Cloak_Off", function ( pl, ent )
		if ( !IsValid( ent ) ) then return false end
		return true
	end )
	
end

function ENT:Initialize()
	if CLIENT then
		bool_or=0
		bool=0
		cloaked_entities={}
		
		
	end
	if SERVER then
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then	
			phys:Wake()
		end	
		self:Switch( false )
		self.on=false
		self.activated=false
		self.CloakedEntities={}
		self.needupdate=false
		self.ind_self_all_ents=0
		self.ind_all_ents=0
		
		
	end
	
end

if SERVER then
	function ENT:Think()
		cl_visible = self.client_visible
		owner      = self.owner
		
		if !self:IsValid() then return end
		if self.clickedon && self.Toggle then -- Toggling
			if self.on==false then
				self.needupdate=true
				self.on=true
				
				if self.on && (self.firstscanned==false or self.firstscanned==nil) then -- actual cloaking 
					for k, v in pairs(ents.FindInSphere(self:GetPos(),self.range)) do
						if !v.cloaked then
							v.cloaked=true
							table.insert(self.CloakedEntities, v)
						end
					end
					
					
					
					if (tonumber(self.const_cloak)==1) then
						for k, v in pairs( constraint.GetAllConstrainedEntities( self ) ) do
							if !v.cloaked then
								v.cloaked=true
								table.insert(self.CloakedEntities, v)
							end
						end
					end
					self.firstscanned=true
				end
				self:EmitSound("gbombs_5/cloaking/romulan_cloak.mp3", 100, 100)		
				net.Start( "gbombs5_romulancloak" )         
					net.WriteTable( self.CloakedEntities )
					net.WriteBit(self.on)
					net.WriteBit(false)		
					if cl_visible=="1" then	
						net.WriteString("true")
					else						
						net.WriteString("false")
					end
					net.WriteEntity(owner)
					
					

				net.Broadcast()
				
			elseif self.on==true then
				if self.Toggle then
					self.on=false		
					self.needupdate=true
					self:EmitSound("gbombs_5/cloaking/romulan_decloak.mp3", 100, 100)
					self.firstscanned=false
					net.Start( "gbombs5_romulancloak" )         
						net.WriteTable( self.CloakedEntities )
						net.WriteBit(self.on)
						net.WriteBit(false)						
						if cl_visible=="1" then	
							net.WriteString("true")
						else
							
							net.WriteString("false")
						end
						net.WriteEntity(owner)
					net.Broadcast()  

				end
			end
				
			self.clickedon=false
		end	
		
		if tonumber(self.phase_inverter)==1 then
			all_ents = ents.GetAll()
			for k, v in pairs( all_ents ) do
			
				if v:IsValid() then
					if v:GetPhysicsObject():IsValid() then
						if v:GetClass()=="worldspawn" then
							table.remove( all_ents, k )
							
						end
						if table.HasValue(self.CloakedEntities, v) then
							table.remove( all_ents, k  )
						
						end
						
					end
				end
			end
			if self.first_nocollide==nil then -- building list of entities first time
				self.first_nocollide=true
				self.all_ents=all_ents
			end
			
			for k, v in pairs( all_ents ) do
				self.ind_all_ents=self.ind_all_ents+1
			end
			for k, v in pairs( self.all_ents  ) do
				self.ind_self_all_ents=self.ind_self_all_ents+1
			end
			
			if self.ind_all_ents!=self.ind_self_all_ents then
				self.ind_self_all_ents=0
				self.ind_all_ents=0
				self.all_ents=all_ents -- updated
				self.needupdate=true
				
			else
				self.ind_self_all_ents=0
				self.ind_all_ents=0
			end
			if self.needupdate==true then
				self.needupdate=false
				print("updated")
				for index_1, cloaked_ent in pairs( self.CloakedEntities ) do
					for index_2, world_ent in pairs( all_ents ) do
						if cloaked_ent:IsValid() && world_ent:IsValid() then
							phys1=cloaked_ent:GetPhysicsObject()
							phys2=world_ent:GetPhysicsObject() 
							if phys1:IsValid() && phys2:IsValid() then
								ent1=cloaked_ent
								ent2=world_ent
								ent1:SetCustomCollisionCheck(true)
								ent2:SetCustomCollisionCheck(true) 
								CloakedEntities=self.CloakedEntities
								On = self.on
								function ShouldCollideHook( ent1, ent2 )
							
									if On then
										if table.HasValue(CloakedEntities, ent1) and table.HasValue(CloakedEntities, ent2) then

										elseif (table.HasValue(CloakedEntities, ent1) and !table.HasValue(CloakedEntities, ent2)) or (table.HasValue(CloakedEntities, ent2) and !table.HasValue(CloakedEntities, ent1)) then
											
											if ent1:GetClass()=="worldspawn" or ent2:GetClass()=="worldspawn" then
												
											else								
												return false
											end

										elseif ent1:GetClass()=="worldspawn" or ent2:GetClass()=="worldspawn" then
											
										end
									else
										if table.HasValue(CloakedEntities, ent1) and table.HasValue(CloakedEntities, ent2) then
										elseif (table.HasValue(CloakedEntities, ent1) and !table.HasValue(CloakedEntities, ent2)) or (table.HasValue(CloakedEntities, ent2) and !table.HasValue(CloakedEntities, ent1)) then						
											if ent1:GetClass()=="worldspawn" or ent2:GetClass()=="worldspawn" then										
											else																	
											end
										elseif ent1:GetClass()=="worldspawn" or ent2:GetClass()=="worldspawn" then -- DONT TOUCH THIS! IT WILL BREAK THE GAME						
										end
									end
								end							
								hook.Add( "ShouldCollide", "ShouldCollideHook", ShouldCollideHook )			
								hook.Remove( "ShouldCollide", "ShouldCollideHook", ShouldCollideHook )	
							end
						end
					end
				end
			end
			
		end
	
		
		if ( SERVER && self.SwitchOffTime && self.SwitchOffTime < CurTime() ) then
			self.SwitchOffTime = nil
		end
		self:NextThink(CurTime() + 0.01)
		return true
	end
end


if CLIENT then
	function ENT:Think()
		net.Receive( "gbombs5_romulancloak", function( len, ply )
			cloaked_entities = net.ReadTable()
			bool 		     = net.ReadBit()
			bool_onremove    = net.ReadBit()
			cl_visible       = net.ReadString()
			cl_owner         = net.ReadEntity()
			
			
		end )
		if cl_owner==LocalPlayer() and cl_visible=="true" then
		else
			for k, v in pairs(cloaked_entities) do
				if v:IsValid() then
					if v.first_time==nil then
						v.first_time=true
						v.alpha=255
						v.originalcolor=v:GetColor().g
						v.originalcolor_f=v:GetColor()
						v.greenfilter=0
						
		
					end
					if (bool==1) then
						
						v:SetRenderMode( RENDERMODE_TRANSALPHA )
						v:SetKeyValue( "renderfx", 0 )
						
						if v.greenfilter <255 then
							v.greenfilter=v.greenfilter+1.5
							
						elseif v.greenfilter<0 then
							
							v.greenfilter=0
						end
						
						if (v.alpha>=0 && v.alpha<256) then
							v.alpha=v.alpha-1.5
							if v.alpha<0 then
								v.alpha=0
							end
							
							v:SetNoDraw(false)
						else
							v.alpha=0
							
							v:SetNoDraw(true)
						end
						
						v:SetColor(Color(255-v.greenfilter, v:GetColor().g,255-v.greenfilter, v.alpha))	
					elseif (bool==0) then
						v:SetRenderMode( RENDERMODE_TRANSALPHA )
						v:SetKeyValue( "renderfx", 0 )
						
						if v.greenfilter>=0 then			
							v.greenfilter=v.greenfilter-1.5				
						elseif v.greenfilter<0 then			
							v.greenfilter=0
						end
						
						if (v.alpha<255) then					
							v.alpha=v.alpha+1.5
							v:SetNoDraw(false)
						else
							v.alpha=255
							v:SetNoDraw(false)
						end

						v:SetColor(Color(255-v.greenfilter, v:GetColor().g, 255-v.greenfilter, v.alpha))	
					end
				end
			end
		end
		
	end
end



if CLIENT then
	function ENT:Draw()
		self:DrawModel()	
	end
end
function ENT:OnRemove()
	if SERVER then
		net.Start( "gbombs5_romulancloak" )         
			net.WriteTable( self.CloakedEntities )
			net.WriteBit(self.on)
			net.WriteBit(1)
			net.WriteString("false")
		net.Broadcast()  
		if self.CloakedEntities!=nil then
			for k, v in pairs(self.CloakedEntities) do
				if v:IsValid() then
					v.cloaked=false
				end
			end
		end
		if tonumber(self.phase_inverter)==1 then
			for k, v in pairs( ents.GetAll() ) do
				if v:GetClass()=="worldspawn" then return end
				if table.HasValue(self.CloakedEntities, v) then
					ent1:SetCustomCollisionCheck(true)
					ent2=v
					ent2:SetCustomCollisionCheck(true)
					function ShouldCollideHook( ent1, ent2 )
						if ( ent1:IsValid() and ent2:IsValid() )  then
							return false
						end 
					end
					hook.Add( "ShouldCollide", "ShouldCollideHook", ShouldCollideHook )
				end
			end
		end
	end
	if CLIENT then
		if cloaked_entities!=nil then
			for k, v in pairs(cloaked_entities) do
				if v:IsValid() then
					v:SetRenderMode( RENDERMODE_TRANSALPHA )
					v:SetKeyValue( "renderfx", 0 )
					v:SetColor(Color(255,255,255,255))
					v:SetNoDraw(false)
				end
			end
		end
	end
end




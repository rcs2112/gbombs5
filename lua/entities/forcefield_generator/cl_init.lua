include('shared.lua')

function ENT:Draw()
	render.SetMaterial( Material("models/alyx/emptool_glow", "nocull") )
	if self:GetNWBool("on", nil)==true then
		render.DrawSphere( self:GetPos(), self:GetNWInt("field_range",nil), 100, 100, Color(0, 0, 0, 0))
	end
	
	self.Entity:DrawModel()
	local squad = self:GetNetworkedString( 12 )
	if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 256 ) then
		AddWorldTip( self.Entity:EntIndex(), ( "Forcefield Generator" ), 0.5, self.Entity:GetPos(), self.Entity  )
	end
end

language.Add( 'forcefield', 'Force Field' )
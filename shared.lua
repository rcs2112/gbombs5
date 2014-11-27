-- Variables that are used on both client and server
SWEP.Gun = ("m9k_nitro") -- must be the name of your swep but NO CAPITALS!
if (GetConVar(SWEP.Gun.."_allowed")) != nil then
	if not (GetConVar(SWEP.Gun.."_allowed"):GetBool()) then SWEP.Base = "bobs_blacklisted" SWEP.PrintName = SWEP.Gun return end
end
SWEP.Category				= "GBombs 5 Sweps"
SWEP.Author				= ""
SWEP.Contact				= ""
SWEP.Purpose				= ""
SWEP.Instructions				= ""
SWEP.MuzzleAttachment			= "1" 	-- Should be "1" for CSS models or "muzzle" for hl2 models
SWEP.ShellEjectAttachment			= "2" 	-- Should be "2" for CSS models or "1" for hl2 models
SWEP.PrintName				= "TVirus"		-- Weapon name (Shown on HUD)	
SWEP.Slot				= 4				-- Slot in the weapon selection menu
SWEP.SlotPos				= 23			-- Position in the slot
SWEP.DrawAmmo				= true		-- Should draw the default HL2 ammo counter
SWEP.DrawWeaponInfoBox			= false		-- Should draw the weapon info box
SWEP.BounceWeaponIcon   		= 	false	-- Should the weapon icon bounce?
SWEP.DrawCrosshair			= false		-- set false if you want no crosshair
SWEP.Weight				= 2			-- rank relative ot other weapons. bigger is better
SWEP.AutoSwitchTo			= true		-- Auto switch to if we pick it up
SWEP.AutoSwitchFrom			= true		-- Auto switch from if you pick up a better weapon
SWEP.HoldType 				= "grenade"		-- how others view you carrying the weapon

SWEP.ViewModelFOV			= 70
SWEP.ViewModelFlip			= true
SWEP.ViewModel				= "models/weapons/v_invisible_nade.mdl"	-- Weapon view model
SWEP.WorldModel				= "models/weapons/w_nitro.mdl"	-- Weapon world model
SWEP.ShowWorldModel			= true
SWEP.Spawnable				= true
SWEP.AdminSpawnable			= true
SWEP.FiresUnderwater 		= true

SWEP.Primary.Sound			= Sound("")		
SWEP.Primary.RPM				= 30		
SWEP.Primary.ClipSize			= 1		
SWEP.Primary.DefaultClip		= 1		
SWEP.Primary.KickUp				= 0		
SWEP.Primary.KickDown			= 0		
SWEP.Primary.KickHorizontal		= 0		
SWEP.Primary.Automatic			= false		
SWEP.Primary.Ammo			= "nitroG"				


SWEP.Primary.Round 			= ("m9k_thrown_nitrox")	--NAME OF ENTITY GOES HERE

SWEP.Secondary.IronFOV			= 0			

SWEP.Primary.NumShots	= 0		
SWEP.Primary.Damage		= 0	
SWEP.Primary.Spread		= 0	
SWEP.Primary.IronAccuracy = 0.1



SWEP.VElements = {
	["bottle_o_boom"] = { type = "Model", model = "models/weapons/w_nitro.mdl", bone = "v_weapon.Flashbang_Parent", rel = "", pos = Vector(-4.538, -7.218, -14.072), angle = Angle(164.236, -6.253, 97.573), size = Vector(0.666, 0.666, 0.666), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

--gimme a fucking break!

SWEP.ViewModelBoneMods = {
	["v_weapon.Left_Middle01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 17.5, 0) },
	["v_weapon.Left_Ring01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 23.271, 0) },
	["v_weapon.Left_Index01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 25.108, 0) },
	["v_weapon.Left_Pinky01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 34.459, 0) }
}

if GetConVar("M9KUniqueSlots") != nil then
	if not (GetConVar("M9KUniqueSlots"):GetBool()) then 
		SWEP.SlotPos = 2
	end
end

function SWEP:PrimaryAttack()
	if self.Owner:IsNPC() then return end
	if self:CanPrimaryAttack() then
		self.Weapon:SendWeaponAnim(ACT_VM_PULLPIN)
		
		self.Weapon:SetNextPrimaryFire(CurTime()+1/(self.Primary.RPM/60))	
		timer.Simple( 0.6, function() if SERVER then if not IsValid(self) then return end 
			if IsValid(self.Owner) then 
				if (self:AllIsWell()) then 
					self:Throw() 
				end 
			end
		end end )
	end
end

function SWEP:Throw()

	if SERVER then
	
	if self.Owner != nil and self.Weapon != nil then 
	if self.Owner:GetActiveWeapon():GetClass() == self.Gun then

	self.Weapon:SendWeaponAnim(ACT_VM_THROW)
	timer.Simple( 0.35, function() if not IsValid(self) then return end 
	if self.Owner != nil
	and self.Weapon != nil
	then if(self:AllIsWell()) then 
	self.Owner:SetAnimation(PLAYER_ATTACK1)
			aim = self.Owner:GetAimVector()
			side = aim:Cross(Vector(0,0,1))
			up = side:Cross(aim)
			pos = self.Owner:GetShootPos() + side * 5 + up * -1
			if SERVER then
				local rocket = ents.Create(self.Primary.Round)
				if !rocket:IsValid() then return false end
				rocket:SetNWEntity("Owner", self.Owner)
				rocket:SetAngles(aim:Angle()+Angle(90,0,0))
				rocket:SetPos(pos)
				rocket:SetOwner(self.Owner)
				rocket.Owner = self.Owner	-- redundancy department of redundancy checking in
				rocket:SetNWEntity("Owner", self.Owner)
				rocket:Spawn()
				local phys = rocket:GetPhysicsObject()
				if self.Owner:KeyDown(IN_ATTACK2) and (phys:IsValid()) then
					if phys != nil then phys:ApplyForceCenter(self.Owner:GetAimVector() * 2000) end
				else 
					if phys != nil then phys:ApplyForceCenter(self.Owner:GetAimVector() * 5500) end
				end
				self.Weapon:TakePrimaryAmmo(1)
		end
		self:checkitycheckyoself()
		end end
	end )
		
	end
	end
	end
end

function SWEP:SecondaryAttack()
end	

function SWEP:checkitycheckyoself()
	timer.Simple(.15, function() if not IsValid(self) then return end 
	if IsValid(self.Owner) then 
	if SERVER and (self:AllIsWell()) then	
		if self.Weapon:Clip1() == 0 
			and self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() ) == 0 then
				self.Owner:StripWeapon(self.Gun)
			else
				self.Weapon:DefaultReload( ACT_VM_DRAW )
			end
		end
	end end)
end

function SWEP:AllIsWell()

	if self.Owner != nil and self.Weapon != nil then
		if self.Weapon:GetClass() == self.Gun and self.Owner:Alive() then
			return true
			else return false
		end
		else return false
	end

end

function SWEP:Think()
end

-- Don't try to edit this file if you're trying to add new vehicles
-- Just make a new file and copy the format below.

local Category = "GB5: Vehicles"

local function HandleRollercoasterAnimation( vehicle, player )
	return player:SelectWeightedSequence( ACT_HL2MP_IDLE ) 
end

local V =  {
	Name = "Standard Driver Pod",
	Class = "prop_vehicle_prisoner_pod",
	Category = Category,

	Author = "Lazermaniac",
	Information = "Modified prisonpod for more realistic player damage",
	Model = "models/props_c17/FurnitureFridge001a.mdl",
	KeyValues = {
					vehiclescript	=	"scripts/vehicles/prisoner_pod.txt",
					limitview		=	"0"
				},
}
list.Set( "Vehicles", "fridge", V )
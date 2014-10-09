AddCSLuaFile()

function gb5_physics()
	Msg("\n|Gbombs 5 physics module initialized!")
	Msg("\n|If you don't want this, delete the gb5_physics.lua file\n")
	Settings = {} 
	Settings.MaxVelocity = 15784
	Settings.MaxAngularVelocity = 15784
	physenv.SetPerformanceSettings(Settings)
end

hook.Add( "InitPostEntity", "gb5_physics", gb5_physics )
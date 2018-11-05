--[[
node_def = {
	group = { flammable = 1 }
	fire_ignite = total heat intensity required to ignite
	fire_intensity = heat level released (0.5x below, 2x above)
	fire_fuel = amount of fuel contained (in intensity-seconds)
	fire_clean = if true, leave no ash
	on_heat = function(pos, node, intensity, frompos) ... end
}
solo-inv take contained items into account!
--]]

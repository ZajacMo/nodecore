-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local checkdirs = {
	{x = 1, y = 0, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 1},
	{x = 0, y = 0, z = -1},
	{x = 0, y = 1, z = 0}
}
nodecore.register_limited_abm({
		label = "Torch Igniting",
		interval = 6,
		chance = 1,
		nodenames = {modname .. ":torch_lit"},
		neighbors = {"group:flammable"},
		action = function(pos)
			for _, ofst in pairs(checkdirs) do
				local npos = vector.add(pos, ofst)
				local nbr = minetest.get_node(npos)
				if minetest.get_item_group(nbr.name, "flammable") > 0
				and not nodecore.quenched(npos) then
					nodecore.fire_check_ignite(npos, nbr)
				end
			end
		end
	})

nodecore.register_limited_abm({
		label = "Torch Extinguishing",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":torch_lit"},
		action = function(pos)
			if nodecore.quenched(pos) or
			nodecore.gametime > minetest.get_meta(pos):get_float("expire") then
				minetest.remove_node(pos)
				minetest.add_item(pos, {name = "nc_fire:lump_ash"})
				minetest.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
			end
		end
	})

nodecore.register_aism({
		label = "Torch Stack Interactions",
		itemnames = {modname .. ":torch_lit"},
		action = function(stack, data)
			local expire = stack:get_meta():get_float("expire") or 0
			if expire < nodecore.gametime then
				minetest.sound_play("nc_fire_snuff", {gain = 1, pos = data.pos})
				return "nc_fire:lump_ash"
			end

			local pos = data.pos
			local player = data.player
			if player then
				if data.list ~= "main" or player:get_wield_index()
				~= data.slot then return end
				pos = vector.add(pos, vector.multiply(player:get_look_dir(), 0.5))
			end

			if nodecore.quenched(pos, data.player and 0 or 1) then
				minetest.sound_play("nc_fire_snuff", {gain = 1, pos = pos})
				return "nc_fire:lump_ash"
			end
			if math_random() < 0.1 then nodecore.fire_check_ignite(pos) end
		end
	})

nodecore.register_ambiance({
		label = "Flame Ambiance",
		nodenames = {modname .. ":torch_lit"},
		interval = 1,
		chance = 1,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.1
	})

-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs
    = minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function findwater(pos)
	return nodecore.find_nodes_around(pos, "group:water")
end

local function soakup(pos)
	local any
	for _, p in pairs(findwater(pos)) do
		nodecore.node_sound(p, "dig")
		minetest.remove_node(p)
		any = true
	end
	return any
end

minetest.register_abm({
		label = "sponge wet",
		interval = 1,
		chance = 10,
		nodenames = {modname .. ":sponge"},
		neighbors = {"group:water"},
		action = function(pos)
			if soakup(pos) then
				nodecore.set_loud(pos, {name = modname .. ":sponge_wet"})
				return nodecore.fallcheck(pos)
			end
		end
	})

nodecore.register_aism({
		label = "sponge stack wet",
		interval = 1,
		chance = 10,
		itemnames = {modname .. ":sponge"},
		action = function(stack, data)
			if data.pos and soakup(data.pos) then
				local taken = stack:take_item(1)
				taken:set_name(modname .. ":sponge_wet")
				if data.inv then taken = data.inv:add_item("main", taken) end
				if not taken:is_empty() then nodecore.item_eject(data.pos, taken) end
				return stack
			end
		end
	})

minetest.register_abm({
		label = "sponge sun dry",
		interval = 1,
		chance = 100,
		nodenames = {modname .. ":sponge_wet"},
		arealoaded = 1,
		action = function(pos)
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if nodecore.is_max_light(above) and #findwater(pos) < 1 then
				nodecore.sound_play("nc_api_craft_hiss", {gain = 0.02, pos = pos})
				return minetest.set_node(pos, {name = modname .. ":sponge"})
			end
		end
	})

nodecore.register_aism({
		label = "sponge stack sun dry",
		interval = 1,
		chance = 100,
		arealoaded = 1,
		itemnames = {modname .. ":sponge_wet"},
		action = function(stack, data)
			if data.player and (data.list ~= "main"
				or data.slot ~= data.player:get_wield_index()) then return end
			if data.pos and nodecore.is_max_light(data.pos)
			and #findwater(data.pos) < 1 then
				nodecore.sound_play("nc_api_craft_hiss", {gain = 0.02, pos = data.pos})
				local taken = stack:take_item(1)
				taken:set_name(modname .. ":sponge")
				if data.inv then taken = data.inv:add_item("main", taken) end
				if not taken:is_empty() then nodecore.item_eject(data.pos, taken) end
				return stack
			end
		end
	})

minetest.register_abm({
		label = "sponge fire dry",
		interval = 1,
		chance = 20,
		nodenames = {modname .. ":sponge_wet"},
		neighbors = {"group:igniter"},
		action = function(pos)
			nodecore.sound_play("nc_api_craft_hiss", {gain = 0.02, pos = pos})
			return minetest.set_node(pos, {name = modname .. ":sponge"})
		end
	})

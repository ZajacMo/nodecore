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

nodecore.register_limited_abm({
		label = "Sponge Wettening",
		interval = 1,
		chance = 10,
		limited_max = 100,
		nodenames = {modname .. ":sponge"},
		neighbors = {"group:water"},
		action = function(pos)
			if soakup(pos) then
				nodecore.set_loud(pos, {name = modname .. ":sponge_wet"})
			end
		end
	})

nodecore.register_aism({
		label = "Sponge Stack Wettening",
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

nodecore.register_limited_abm({
		label = "Sponge Drying in Sunlight",
		interval = 1,
		chance = 100,
		limited_max = 100,
		nodenames = {modname .. ":sponge_wet"},
		action = function(pos)
			if minetest.get_node_light(pos) >= 15 and #findwater(pos) < 1 then
				minetest.sound_play("nc_api_craft_hiss", {gain = 0.02, pos = pos})
				return minetest.set_node(pos, {name = modname .. ":sponge"})
			end
		end
	})

nodecore.register_aism({
		label = "Sponge Stack Drying in Sunlight",
		interval = 1,
		chance = 100,
		itemnames = {modname .. ":sponge_wet"},
		action = function(stack, data)
			if data.player and (data.list ~= "main"
				or data.slot ~= data.player:get_wield_index()) then return end
			local ll = data.pos and minetest.get_node_light(data.pos)
			if ll and ll >= 15 and #findwater(data.pos) < 1 then
				minetest.sound_play("nc_api_craft_hiss", {gain = 0.02, pos = data.pos})
				local taken = stack:take_item(1)
				taken:set_name(modname .. ":sponge")
				if data.inv then taken = data.inv:add_item("main", taken) end
				if not taken:is_empty() then nodecore.item_eject(data.pos, taken) end
				return stack
			end
		end
	})

nodecore.register_limited_abm({
		label = "Sponge Drying near Fire",
		interval = 1,
		chance = 20,
		limited_max = 100,
		nodenames = {modname .. ":sponge_wet"},
		neighbors = {"group:igniter"},
		action = function(pos)
			minetest.sound_play("nc_api_craft_hiss", {gain = 0.02, pos = pos})
			return minetest.set_node(pos, {name = modname .. ":sponge"})
		end
	})

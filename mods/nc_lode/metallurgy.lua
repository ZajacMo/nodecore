-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local hotitems = {}

local function reg(shape, rawdef)
	for _, temper in pairs({"Hot", "Annealed", "Tempered"}) do
		local def = nodecore.underride({}, rawdef)
		def = nodecore.underride(def, {
				description = temper .. " Lode " .. shape,
				name = (shape .. "_" .. temper):lower(),
				groups = { cracky = 3 },
				["metal_temper_" .. temper:lower()] = true,
				metal_alt_hot = modname .. ":" .. shape:lower() .. "_hot",
				metal_alt_annealed = modname .. ":" .. shape:lower() .. "_annealed",
				metal_alt_tempered = modname .. ":" .. shape:lower() .. "_tempered",
			})
		if temper ~= "Hot" then
			def.light_source = nil
		else
			def.groups = def.groups or {}
			def.groups.falling_node = 1
			def.damage_per_second = 2
		end

		if def.tiles then
			local t = {}
			for k, v in pairs(def.tiles) do
				t[k] = v:gsub("#", temper:lower())
			end
			def.tiles = t
		end
		def.inventory_image = def.inventory_image and 
		def.inventory_image:gsub("#", temper:lower())

		minetest.register_item(modname .. ":" .. def.name, def)
	end
end

reg("Prill", {
		type = "craft",
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_mask_prill.png"
	})
reg("Slab", {
		type = "node",
		drawtype = "nodebox",
		node_box = nodecore.fixedbox(-0.5, -0.5, -0.5, 0.5, 0, 0.5),
		tiles = { modname .. "_#.png" },
		paramtype = "light",
		light_source = 6,
		crush_damage = 1
	})
reg("Block", {
		type = "node",
		tiles = { modname .. "_#.png" },
		light_source = 8,
		crush_damage = 4
	})

local flame = {groups = {flame = true}}
local function heated(pos)
	if nodecore.quenched(pos) then return end
	local f = 0
	if nodecore.node_is({x = pos.x, y = pos.y - 1, z = pos.z}, flame)
	then f = f + 1 end
	if nodecore.node_is({x = pos.x + 1, y = pos.y, z = pos.z}, flame)
	then f = f + 1 end
	if nodecore.node_is({x = pos.x - 1, y = pos.y, z = pos.z}, flame)
	then f = f + 1 end
	if f >= 3 then return true end
	if nodecore.node_is({x = pos.x, y = pos.y, z = pos.z + 1}, flame)
	then f = f + 1 end
	if f >= 3 then return true end
	if nodecore.node_is({x = pos.x, y = pos.y, z = pos.z - 1}, flame)
	then f = f + 1 end
	if f >= 3 then return true end
end

local function timecounter(meta, max, check)
	if not check then
		meta:from_table({})
		return
	end
	local t = (meta:get_int("time") or 0) + 1
	if t >= max then return true end
	meta:set_int("time", t)
end

nodecore.register_limited_abm({
		label = "Lode Cobble to Prills",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":cobble"},
		neighbors = {"group:flame"},
		action = function(pos, node)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			if timecounter(minetest:get_meta(pos), 30,
				not nodecore.node_is(below, {walkable = true}) and heated(pos)) then
				nodecore.item_eject(below, modname .. ":prill_hot 2")
				minetest:get_meta(pos):from_table({})
				return nodecore.set_node(pos, {name = "nc_terrain:cobble"})
			end
		end})

local function replacestack(pos, name, stack)
	nodecore.remove_node(pos)
	return nodecore.item_eject(pos, name .. " " .. stack:get_count())
end

nodecore.register_limited_abm({
		label = "Lode Stack Heating/Cooling",
		interval = 1,
		chance = 1,
		nodenames = {"group:visinv"},
		action = function(pos, node)
			local inv = minetest.get_meta(pos):get_inventory()
			local stack = inv:get_stack("solo", 1)
			if stack:is_empty() then return end
			local def = minetest.registered_items[stack:get_name()]
			if not def then return end
			if def.metal_temper_hot then
				if nodecore.quenched(pos) then
					return replacestack(pos, def.metal_alt_tempered, stack)
				end
				if timecounter(stack:get_meta(), 120, not heated(pos)) then
					return replacestack(pos, def.metal_alt_annealed, stack)
				end
			elseif timecounter(stack:get_meta(), 30, heated(pos)) then
				return replacestack(pos, def.metal_alt_hot, stack)
			end
			return inv:set_stack("solo", 1, stack)
		end})

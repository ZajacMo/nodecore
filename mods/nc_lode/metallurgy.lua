-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, type
    = ItemStack, math, minetest, nodecore, pairs, type
local math_exp, math_floor, math_log, math_random
    = math.exp, math.floor, math.log, math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

function nodecore.register_lode(shape, rawdef)
	for _, temper in pairs({"Hot", "Annealed", "Tempered"}) do
		local def = nodecore.underride({}, rawdef)
		local snd = temper:lower()
		if snd == "hot" then snd = "annealed" end
		def = nodecore.underride(def, {
				description = temper .. " Lode " .. shape,
				name = (shape .. "_" .. temper):lower():gsub(" ", "_"),
				groups = { cracky = 3 },
				["metal_temper_" .. temper:lower()] = true,
				metal_alt_hot = modname .. ":" .. shape:lower() .. "_hot",
				metal_alt_annealed = modname .. ":" .. shape:lower() .. "_annealed",
				metal_alt_tempered = modname .. ":" .. shape:lower() .. "_tempered",
				sounds = nodecore.sounds("nc_lode_" .. snd)
			})
		def.metal_temper_cool = (not def.metal_temper_hot) or nil
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
		for k, v in pairs(def) do
			if type(v) == "string" then
				def[k] = v:gsub("##", temper):gsub("#", temper:lower())
			end
		end

		if def.bytemper then def.bytemper(temper, def) end

		minetest.register_item(modname .. ":" .. def.name, def)
	end
end

nodecore.register_lode("Block", {
		type = "node",
		description = "## Lode",
		tiles = { modname .. "_#.png" },
		light_source = 8,
		crush_damage = 4
	})

nodecore.register_lode("Prill", {
		type = "craft",
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_mask_prill.png",
	})

local logadj = math_log(2)
local function exporand()
	local r = 0
	while r == 0 do r = math_random() end
	return math_floor(math_exp(-math_log(r) * logadj))
end

nodecore.register_craft({
		label = "lode cobble to prills",
		action = "cook",
		touchgroups = {flame = 3},
		duration = 30,
		cookfx = true,
		check = function(pos)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			return not nodecore.match(below, {walkable = true})
		end,
		nodes = {
			{
				match = modname .. ":cobble",
				replace = "nc_terrain:cobble"
			}
		},
		after = function(pos)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			return nodecore.item_eject(below, modname
				.. ":prill_hot " .. exporand())
		end
	})

nodecore.register_cook_abm({nodenames = {modname .. ":cobble"}, neighbors = {"group:flame"}})

local function replacestack(pos, alt)
	local stack = nodecore.stack_get(pos)
	nodecore.remove_node(pos)
	local def = minetest.registered_items[stack:get_name()] or {}
	local repl = ItemStack(def["metal_alt_" .. alt] or "")
	repl:set_count(stack:get_count() * repl:get_count())
	return nodecore.item_eject(pos, repl)
end

nodecore.register_craft({
		label = "lode stack heating",
		action = "cook",
		touchgroups = {flame = 3},
		duration = 30,
		cookfx = true,
		nodes = {{match = {metal_temper_cool = true, stacked = true, count = false}}},
		after = function(pos) return replacestack(pos, "hot") end
	})

nodecore.register_craft({
		label = "lode stack annealing",
		action = "cook",
		touchgroups = {flame = 0},
		duration = 120,
		priority = -1,
		cookfx = {smoke = true, hiss = true},
		nodes = {{match = {metal_temper_hot = true, stacked = true, count = false}}},
		after = function(pos) return replacestack(pos, "annealed") end
	})

nodecore.register_craft({
		label = "lode stack quenching",
		action = "cook",
		touchgroups = {flame = 0},
		check = function(pos)
			return #minetest.find_nodes_in_area(
				{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
				{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
				{"group:coolant"}) > 0
		end,
		cookfx = true,
		nodes = {{match = {metal_temper_hot = true, stacked = true, count = false}}},
		after = function(pos) return replacestack(pos, "tempered") end
	})

-- Because of how massive they are, forging a block is a hot-working process.
nodecore.register_craft({
		label = "forge lode block",
		action = "pummel",
		toolgroups = {thumpy = 3},
		nodes = {
			{
				match = {name = modname .. ":prill_hot", count = 8},
				replace = "air"
			}
		},
		items = {
			modname .. ":block_hot"
		}
	})

-- Blocks can be chopped back into prills using only hardened tools.
nodecore.register_craft({
		label = "break apart lode block",
		action = "pummel",
		toolgroups = {choppy = 5},
		nodes = {
			{
				match = modname .. ":block_annealed",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":prill_annealed 2", count = 4, scatter = 5}
		}
	})

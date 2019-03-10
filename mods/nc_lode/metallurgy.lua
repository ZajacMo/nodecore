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
		def = nodecore.underride(def, {
				description = temper .. " Lode " .. shape,
				name = (shape .. "_" .. temper):lower():gsub(" ", "_"),
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
		description = "## Lode Cube",
		tiles = { modname .. "_#.png" },
		light_source = 8,
		crush_damage = 4
	})

nodecore.register_lode("Prill", {
		type = "craft",
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_mask_prill.png",
	})

local flame = {groups = {flame = true}}
local function heated(pos)
	if nodecore.quenched(pos) then return end
	local f = 0
	if nodecore.match({x = pos.x, y = pos.y - 1, z = pos.z}, flame)
	then f = f + 1 end
	if nodecore.match({x = pos.x + 1, y = pos.y, z = pos.z}, flame)
	then f = f + 1 end
	if nodecore.match({x = pos.x - 1, y = pos.y, z = pos.z}, flame)
	then f = f + 1 end
	if f >= 3 then return true end
	if nodecore.match({x = pos.x, y = pos.y, z = pos.z + 1}, flame)
	then f = f + 1 end
	if f >= 3 then return true end
	if nodecore.match({x = pos.x, y = pos.y, z = pos.z - 1}, flame)
	then f = f + 1 end
	if f >= 3 then return true end
end

local logadj = math_log(2)
local function exporand()
	local r = 0
	while r == 0 do r = math_random() end
	return math_floor(math_exp(-math_log(r) * logadj))
end

nodecore.register_limited_abm({
		label = "Lode Cobble to Prills",
		interval = 1,
		chance = 1,
		nodenames = {modname .. ":cobble"},
		neighbors = {"group:flame"},
		action = function(pos, node)
			local below = {x = pos.x, y = pos.y - 1, z = pos.z}
			if nodecore.cooking(minetest.get_meta(pos), "time", 30,
				not nodecore.match(below, {walkable = true}) and heated(pos),
				pos) then
				nodecore.item_eject(below, modname .. ":prill_hot " .. exporand())
				return nodecore.set_node(pos, {name = "nc_terrain:cobble"})
			end
		end})

local function replacestack(pos, name, stack)
	nodecore.remove_node(pos)
	local repl = ItemStack(name)
	repl:set_count(repl:get_count() * stack:get_count())
	return nodecore.item_eject(pos, repl)
end

nodecore.register_limited_abm({
		label = "Lode Stack Heating/Cooling",
		interval = 1,
		chance = 1,
		nodenames = {"group:visinv"},
		action = function(pos, node)
			local stack = nodecore.stack_get(pos)
			if stack:is_empty() then return end
			local def = minetest.registered_items[stack:get_name()]
			if not def then return end
			if def.metal_temper_hot then
				if nodecore.quenched(pos) then
					return replacestack(pos, def.metal_alt_tempered, stack)
				end
				if nodecore.cooking(stack:get_meta(), "time", 120,
					not heated(pos), pos) then
					return replacestack(pos, def.metal_alt_annealed, stack)
				end
			elseif (def.metal_temper_annealed or def.metal_temper_tempered)
			and nodecore.cooking(stack:get_meta(), "time", 30, heated(pos), pos) then
				return replacestack(pos, def.metal_alt_hot, stack)
			end
			return nodecore.stack_set(pos, stack)
		end})

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
			{name = modname .. ":prill_annealed", count = 8, scatter = 5}
		}
	})

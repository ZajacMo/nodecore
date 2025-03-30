-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, error, nc, pairs, type
    = ItemStack, core, error, nc, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local tempers = {
	{
		name = "hot",
		desc = "Glowing",
		sound = "annealed",
		glow = true,
		mapcolor = {r = 131, g = 23, b = 18},
	},
	{
		name = "annealed",
		desc = "Annealed",
		sound = "annealed",
		mapcolor = {r = 47, g = 36, b = 32},
	},
	{
		name = "tempered",
		desc = "Tempered",
		sound = "tempered",
		mapcolor = {r = 57, g = 39, b = 35},
	}
}

function nc.register_lode(shape, rawdef)
	rawdef.groups = rawdef.groups or {}
	for _, temper in pairs(tempers) do
		local def = nc.underride({}, rawdef)
		def.groups = nc.underride({}, def.groups)
		def = nc.underride(def, {
				description = temper.desc .. " Lode " .. shape,
				name = (shape .. "_" .. temper.name):lower():gsub(" ", "_"),
				groups = {
					cracky = 3,
					metallic = 1,
					falling_node = temper.name == "hot" and 1 or nil,
					falling_mapgen_ignore = temper.name == "hot"
					and 1 or nil,
					["lode_temper_" .. temper.name] = 1
				},
				["lode_temper_" .. temper.name] = true,
				lode_alt_hot = modname .. ":" .. shape:lower() .. "_hot",
				lode_alt_annealed = modname .. ":" .. shape:lower() .. "_annealed",
				lode_alt_tempered = modname .. ":" .. shape:lower() .. "_tempered",
				sounds = nc.sounds("nc_lode_" .. temper.sound),
				mapcolor = temper.mapcolor,
			})
		def.lode_temper_cool = (not def.lode_temper_hot) or nil
		if not temper.glow then
			def.light_source = nil
		else
			def.groups.falling_node = 1
			def.groups.falling_mapgen_ignore = 1
			def.groups.damage_pickup = 1
			def.groups.damage_radiant = 1
		end

		if def.tiles then
			local t = {}
			for k, v in pairs(def.tiles) do
				t[k] = v:gsub("#", temper.name)
			end
			def.tiles = t
		end
		for k, v in pairs(def) do
			if type(v) == "string" then
				def[k] = v:gsub("##", temper.desc):gsub("#", temper.name)
			end
		end

		if def.bytemper then def.bytemper(temper, def) end

		if not def.skip_register then
			local fullname = ":" .. modname .. ":" .. def.name
			core.register_item(fullname, def)
			if def.type == "node" then
				nc.register_cook_abm({
						nodenames = {fullname},
						neighbors = (not temper.glow) and {"group:flame"} or nil
					})
			end
		end
	end
end

nc.register_lode("Block", {
		type = "node",
		description = "## Lode",
		tiles = {modname .. "_#.png"},
		groups = {lode_cube = 1},
		light_source = 8,
		crush_damage = 4
	})

nc.register_lode("Prill", {
		type = "craft",
		groups = {lode_prill = 1},
		light_source = 1,
		inventory_image = modname .. "_#.png^[mask:" .. modname .. "_mask_prill.png",
	})

local function replacestack(pos, temper)
	local stack = nc.stack_get(pos)
	if stack:is_empty() then stack = nil end
	local node = core.get_node(pos)
	local name = stack and stack:get_name() or node.name
	local def = core.registered_items[name] or {}
	local alt = def["lode_alt_" .. temper]
	if not alt then return error("no " .. alt .. " alt for " .. name) end
	if stack then
		local repl = ItemStack(alt)
		local qty = stack:get_count()
		if qty == 0 then qty = 1 end
		repl:set_count(qty * repl:get_count())
		nc.stack_set(pos, repl)
	else
		core.set_node(pos, {name = alt})
		nc.fallcheck(pos)
	end
	nc.witness(pos, "metallurgize " .. alt)
end

nc.register_craft({
		label = "lode stack heating",
		action = "cook",
		touchgroups = {flame = 3},
		neargroups = {coolant = 0},
		duration = 30,
		cookfx = true,
		nodes = {{match = {lode_temper_cool = true, count = false}}},
		after = function(pos) return replacestack(pos, "hot") end
	})

nc.register_craft({
		label = "lode stack annealing",
		action = "cook",
		touchgroups = {flame = 0},
		neargroups = {coolant = 0},
		duration = 120,
		priority = -1,
		cookfx = {smoke = true, hiss = true},
		nodes = {{match = {lode_temper_hot = true, count = false}}},
		after = function(pos) return replacestack(pos, "annealed") end
	})

nc.register_craft({
		label = "lode stack quenching",
		action = "cook",
		touchgroups = {flame = 0},
		neargroups = {coolant = 1},
		cookfx = true,
		nodes = {{match = {lode_temper_hot = true, count = false}}},
		after = function(pos) return replacestack(pos, "tempered") end
	})

-- Because of how massive they are, forging a block is a hot-working process.
nc.register_craft({
		label = "forge lode block",
		action = "pummel",
		toolgroups = {thumpy = 3},
		priority = 10,
		indexkeys = {modname .. ":prill_hot"},
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
nc.register_craft({
		label = "break apart lode block",
		action = "pummel",
		toolgroups = {choppy = 5},
		indexkeys = {modname .. ":block_hot"},
		nodes = {
			{
				match = modname .. ":block_hot",
				replace = "air"
			}
		},
		items = {
			{name = modname .. ":prill_hot 2", count = 4, scatter = 5}
		}
	})

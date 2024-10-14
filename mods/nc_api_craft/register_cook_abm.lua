-- LUALOCALS < ---------------------------------------------------------
local core, nc, type
    = core, nc, type
-- LUALOCALS > ---------------------------------------------------------

local modname = core.get_current_modname()

local function getduration(_, data)
	local meta = core.get_meta(data.node)

	local md = meta:get_string(modname) or ""
	md = (md ~= "") and core.deserialize(md) or {}

	if md.label ~= data.recipe.label
	or md.count ~= nc.stack_get(data.node):get_count()
	or not md.start
	then return 0 end

	return nc.gametime - md.start
end

local function playcookfx(pos, cookfx, sound, smokeqty, smoketime)
	if not cookfx then return end
	if cookfx == true or cookfx and cookfx[sound] then
		nc.sound_play("nc_api_craft_" .. sound,
			{gain = 1, pos = pos})
	end
	if cookfx == true or cookfx and cookfx.smoke then
		if cookfx ~= true and type(cookfx.smoke) == "number" then
			smokeqty = smokeqty * cookfx.smoke
		end
		nc.smokefx(pos, smoketime, smokeqty)
	end
end
nc.playcookfx = playcookfx

local function inprogress(pos, data)
	local meta = core.get_meta(data.node)
	local recipe = data.recipe

	local md = meta:get_string(modname) or ""
	md = (md ~= "") and core.deserialize(md) or {}

	local count = nc.stack_get(data.node):get_count()
	if md.label ~= recipe.label or md.count ~= count or not md.start then
		md = {
			label = recipe.label,
			count = count,
			start = nc.gametime
		}
		meta:set_string(modname, core.serialize(md))
	end

	data.progressing = true

	return playcookfx(pos, recipe.cookfx, "sizzle", 2, 1)
end

local function cookdone(pos, data)
	local meta = core.get_meta(pos)
	local recipe = data.recipe
	meta:set_float(recipe.label, 0)
	nc.dynamic_shade_add(pos, 1)
	return playcookfx(pos, recipe.cookfx, "hiss", 80, 0.2)
end

local function mkdata()
	return {
		action = "cook",
		duration = getduration,
		inprogress = inprogress,
		after = cookdone
	}
end
nc.craft_cooking_data = mkdata

local dntname = modname .. ":cookcheck"

local function resetcook(pos)
	local meta = core.get_meta(pos)
	if meta:get_string(modname) ~= "" then
		return meta:set_string(modname, "")
	end
end
nc.craft_cooking_reset_meta = resetcook

local function cookcheck(pos, node)
	node = node or core.get_node(pos)
	local data = mkdata()
	nc.craft_check(pos, node, data)
	if not data.progressing then
		resetcook(pos)
	else
		return nc.dnt_set(pos, dntname)
	end
end

nc.register_dnt({
		name = dntname,
		time = 1,
		arealoaded = 1,
		action = cookcheck
	})

local cooknames = {}
function nc.register_cook_abm(def)
	def.label = def.label or "cook " .. core.write_json(def.nodenames)
	def.interval = def.interval or 1
	def.chance = def.chance or 1
	def.arealoaded = def.arealoaded or 1
	def.action = cookcheck
	nc.group_expand(def.nodenames, function(k) cooknames[k] = true end)
	core.register_abm(def)
end

nc.register_on_nodeupdate({
		ignore = {
			remove_node = true,
			dig_node = true,
			add_node_level = true,
			liquid_transformed = true,
		},
		getnode = true,
		func = function(pos, node)
			if cooknames[node.name] then cookcheck(pos, node) end
		end
	})

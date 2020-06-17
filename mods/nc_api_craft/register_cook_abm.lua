-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function getduration(_, data)
	local meta = minetest.get_meta(data.node)

	local md = meta:get_string(modname) or ""
	md = (md ~= "") and minetest.deserialize(md) or {}

	if md.label ~= data.recipe.label
	or md.count ~= nodecore.stack_get(data.node):get_count()
	or not md.start
	then return 0 end

	return nodecore.gametime - md.start
end

local function playcookfx(pos, cookfx, sound, smokeqty, smoketime)
	if not cookfx then return end
	if cookfx == true or cookfx and cookfx[sound] then
		nodecore.sound_play("nc_api_craft_" .. sound,
			{gain = 1, pos = pos})
	end
	if cookfx == true or cookfx and cookfx.smoke then
		if cookfx ~= true and type(cookfx.smoke) == "number" then
			smokeqty = smokeqty * cookfx.smoke
		end
		nodecore.smokefx(pos, smoketime, smokeqty)
	end
end

local function inprogress(pos, data)
	local meta = minetest.get_meta(data.node)
	local recipe = data.recipe

	local md = meta:get_string(modname) or ""
	md = (md ~= "") and minetest.deserialize(md) or {}

	local count = nodecore.stack_get(data.node):get_count()
	if md.label ~= recipe.label or md.count ~= count or not md.start then
		md = {
			label = recipe.label,
			count = count,
			start = nodecore.gametime
		}
		meta:set_string(modname, minetest.serialize(md))
	end

	data.progressing = true

	return playcookfx(pos, recipe.cookfx, "sizzle", 2, 1)
end

local function cookdone(pos, data)
	local meta = minetest.get_meta(pos)
	local recipe = data.recipe
	meta:set_float(recipe.label, 0)
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
nodecore.craft_cooking_data = mkdata

function nodecore.register_cook_abm(def)
	def.label = def.label or "cook " .. minetest.write_json(def.nodenames)
	def.interval = def.interval or 1
	def.chance = def.chance or 1
	def.action = function(pos, node)
		local data = mkdata()
		nodecore.craft_check(pos, node, data)
		if not data.progressing then
			minetest.get_meta(pos):set_string(modname, "")
		end
	end
	nodecore.register_limited_abm(def)
end

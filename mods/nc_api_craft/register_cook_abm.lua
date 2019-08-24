-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, type
    = minetest, nodecore, type
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function getduration(data, recipe)
	local meta = minetest.get_meta(data.node)

	local md = meta:get_string(modname) or ""
	md = (md ~= "") and minetest.deserialize(md) or {}

	if md.label ~= recipe.label
	or md.count ~= nodecore.stack_get(data.node):get_count()
	or not md.start
	then return 0 end

	return minetest.get_gametime() - md.start
end

local function inprogress(data, recipe)
	local meta = minetest.get_meta(data.node)

	local md = meta:get_string(modname) or ""
	md = (md ~= "") and minetest.deserialize(md) or {}

	local count = nodecore.stack_get(data.node):get_count()
	if md.label ~= recipe.label or md.count ~= count or not md.start then
		md = {
			label = recipe.label,
			count = count,
			start = minetest.get_gametime()
		}
		meta:set_string(modname, minetest.serialize(md))
	end

	data.progressing = true

	if recipe.cookfx == true or recipe.cookfx and recipe.cookfx.sizzle then
		minetest.sound_play("nc_api_craft_sizzle", {gain = 1, pos = data.node})
	end
	if recipe.cookfx == true or recipe.cookfx and recipe.cookfx.smoke then
		local qty = 2
		if type(recipe.cookfx.smoke) == "number" then
			qty = qty * recipe.cookfx.smoke
		end
		nodecore.smokefx(data.node, 1, qty)
	end
end

local function cookdone(pos, rel, data, recipe)
	local meta = minetest.get_meta(pos)
	meta:set_float(recipe.label, 0)
	if recipe.cookfx == true or recipe.cookfx and recipe.cookfx.hiss then
		minetest.sound_play("nc_api_craft_hiss", {gain = 1, pos = data.node})
	end
	if recipe.cookfx == true or recipe.cookfx and recipe.cookfx.smoke then
		nodecore.smokefx(data.node, 0.2, 80)
	end
end

function nodecore.register_cook_abm(def)
	def.interval = def.interval or 1
	def.chance = def.chance or 1
	def.action = function(pos, node)
		local data = {
			action = "cook",
			duration = getduration,
			inprogress = inprogress,
			after = cookdone
		}
		nodecore.craft_check(pos, node, data)
		if not data.progressing then
			minetest.get_meta(pos):set_string(modname, "")
		end
	end
	nodecore.register_limited_abm(def)
end

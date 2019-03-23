-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local function getduration(data, recipe)
	local meta = minetest.get_meta(data.node)
	local t = meta:get_float(recipe.label)
	if t and t ~= 0 then return minetest.get_gametime() - t end
	return 0
end

local function inprogress(data, recipe)
	local meta = minetest.get_meta(data.node)
	local t = meta:get_float(recipe.label)
	if (not t) or t == 0 then
		meta:set_float(recipe.label, minetest.get_gametime())
	end
	if recipe.cookfx == true or recipe.cookfx and recipe.cookfx.sizzle then
		minetest.sound_play("nc_api_craft_sizzle", {gain = 0.1, pos = data.node})
	end
	if recipe.cookfx == true or recipe.cookfx and recipe.cookfx.smoke then
		nodecore.smokefx(data.node, 1)
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
	end
	nodecore.register_limited_abm(def)
end

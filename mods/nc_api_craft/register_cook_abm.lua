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
	if not recipe.nosizzle then
		minetest.sound_play("nc_api_craft_sizzle", {gain = 0.1, pos = data.node})
	end
	return nodecore.smokefx(data.node, 1)
end

local function cookdone(pos, rel, data)
	minetest.sound_play("nc_api_craft_hiss", {gain = 1, pos = data.node})
	return nodecore.smokefx(data.node, 0.1, 8)
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

-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, vector
    = minetest, nodecore, vector
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local nodepref = modname .. ":glyph"
local coallump = "nc_fire:lump_coal"

for i = 1, #nodecore.writing_glyphs do
	local glyph = nodecore.writing_glyphs[i]
	local desc = glyph.name .. " Charcoal Glyph"

	local tile = glyph.flipped
	and (modname .. "_glyph_" .. glyph.flipped .. ".png^[transformFX")
	or (modname .. "_glyph_" .. glyph.name:lower() .. ".png")
	tile = "nc_fire_coal_4.png^[mask:" .. tile

	minetest.register_node(nodepref .. i, {
			description = desc,
			tiles = {
				tile,
				"[combine:1x1"
			},
			use_texture_alpha = "clip",
			drawtype = "nodebox",
			node_box = nodecore.fixedbox(
				{-0.5, -15/32, -0.5, 0.5, -14/32, 0.5}
			),
			paramtype = "light",
			paramtype2 = "facedir",
			sunlight_propagates = true,
			walkable = false,
			buildable_to = true,
			pointable = false,
			groups = {
				flammable = 1,
				alpha_glyph = 1
			},
			drop = coallump,
			floodable = true,
			sounds = nodecore.sounds("nc_terrain_crunchy"),
			on_node_touchthru = function(pos, node, under, player)
				local raw = nodecore.touchtip_node(under, nil, player)
				if raw and vector.equals(vector.subtract(under, pos),
					nodecore.facedirs[node.param2].b) then
					return raw .. "\n" .. desc
				end
				return raw
			end
		})
end

local oldcsff = minetest.check_single_for_falling
function minetest.check_single_for_falling(pos, ...)
	local node = minetest.get_node_or_nil(pos)
	if not node then return oldcsff(pos, ...) end
	if minetest.get_item_group(node.name, "alpha_glyph") ~= 0 then
		local dp = vector.add(pos, nodecore.facedirs[node.param2].b)
		if not nodecore.writing_writable(dp, nil, true) then
			minetest.remove_node(pos)
			return true
		end
	end
	return oldcsff(pos, ...)
end

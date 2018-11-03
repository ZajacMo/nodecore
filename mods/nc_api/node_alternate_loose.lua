-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
    = minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

local function underride(to, from)
	for k, v in pairs(from) do
		to[k] = to[k] or v
	end
	return to
end

local looseimg = "^nc_api_loose.png"

nodecore.register_on_register_node(function(name, def)
		local loose = def.alternate_loose
		if not loose then return end

		if not loose.tiles then
			loose.tiles = underride({}, def.tiles)
			for k, v in pairs(loose.tiles) do
				if type(v) == "string" then
					loose.tiles[k] = v .. looseimg
				elseif type(v) == "table" then
					loose.tiles[k] = underride({
							name = v.name .. looseimg
							}, v)
				end
			end
		end

		underride(loose, def)

		loose.name = name .. "_loose"
		loose.description = "Loose " .. loose.description
		loose.groups = underride({}, loose.groups or {})
		loose.groups.falling_node = 1

		if loose.groups.crumbly and not loose.no_repack then
			loose.on_pummel = loose.on_pummel or function(pos, node, stats)
				if stats.duration < 3 then return end
				if not stats.puncher:get_wielded_item()
				:get_tool_capabilities().damage_groups.slappy then return end
				minetest.set_node(pos, {name = name})
			end
		end

		loose.alternate_loose = nil
		loose.alternate_solid = nil
		minetest.register_node(loose.name, loose)

		local solid = underride(def.alternate_solid or {}, def)
		solid.drop_in_place = solid.drop_in_place or loose.name

		solid.alternate_loose = nil
		solid.alternate_solid = nil
		minetest.register_node(name, solid)

		return true
	end)

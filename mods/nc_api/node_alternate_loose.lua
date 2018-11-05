-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, type
= minetest, nodecore, pairs, type
-- LUALOCALS > ---------------------------------------------------------

--[[
Nodes that have an "alternate_loose = { ... }" definition when
registered will be registered as a pair, one being the "loose" version
and the other being the normal "solid" one.  Solid-specific attributes
can be set via "alternate_solid = { ... }".  The solid version will
transform to the loose one when dug, and the loose to solid when
pummeled.
--]]

local function underride(to, from)
	for k, v in pairs(from) do
		to[k] = to[k] or v
	end
	return to
end

local looseimg = "^nc_api_loose.png"

local function can_repack(pos, node, stats)
	local wield = stats.puncher:get_wielded_item()
	if not wield then return end
	local dg = wield:get_tool_capabilities().damage_groups
	return dg and dg.slappy
end
function nodecore.pummel_repack_node(duration, replace)
	if type(replace) ~= "table" then replace = {name = replace} end
	return function (pos, node, stats)
		if stats.duration < duration then return end
		minetest.set_node(pos, replace)
		return true
	end
end

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
			loose.on_pummel = loose.on_pummel
			or nodecore.pummel_repack_node(3, name)
			loose.can_pummel = loose.can_pummel or can_repack
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

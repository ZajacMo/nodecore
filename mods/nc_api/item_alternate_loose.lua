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

local looseimg = "^nc_api_loose.png"

local function can_repack(level)
	return function(pos, node, stats)
		return nodecore.toolspeed(stats.puncher:get_wielded_item(), {thumpy = level})
	end
end

local function repack_node(mult, replace)
	if type(replace) ~= "table" then replace = {name = replace} end
	return function (pos, node, stats)
		if stats.duration < (mult * stats.check) then return end
		nodecore.wear_current_tool(stats.puncher, {thumpy = 1})
		minetest.set_node(pos, replace)
		return true
	end
end

nodecore.register_on_register_item(function(name, def)
		if def.type ~= "node" then return end

		local loose = def.alternate_loose
		if not loose then return end

		if not loose.tiles then
			loose.tiles = nodecore.underride({}, def.tiles)
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

		nodecore.underride(loose, def)

		loose.name = name .. "_loose"
		if loose.oldnames then
			for k, v in pairs(loose.oldnames) do
				loose.oldnames[k] = v .. "_loose"
			end
		end
		loose.description = "Loose " .. loose.description
		loose.groups = nodecore.underride({}, loose.groups or {})
		loose.groups.falling_node = 1

		if loose.groups.crumbly and not loose.no_repack then
			-- PUMDEF
			nodecore.add_pummel(loose,
				can_repack(loose.repack_level or 1),
				repack_node(loose.repack_time or 1, name))
		end

		loose.alternate_loose = nil
		loose.alternate_solid = nil
		minetest.register_node(loose.name, loose)

		local solid = nodecore.underride(def.alternate_solid or {}, def)
		solid.drop_in_place = solid.drop_in_place or loose.name

		solid.alternate_loose = nil
		solid.alternate_solid = nil
		minetest.register_node(name, solid)

		return true
	end)

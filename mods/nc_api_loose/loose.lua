-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, type
    = math, minetest, nodecore, pairs, type
local math_pow
    = math.pow
-- LUALOCALS > ---------------------------------------------------------

--[[
Nodes that have an "alternate_loose = { ... }" definition when
registered will be registered as a pair, one being the "loose" version
and the other being the normal "solid" one. Solid-specific attributes
can be set via "alternate_solid = { ... }". The solid version will
transform to the loose one when dug, and the loose to solid when
pummeled.
--]]

local looseimg = "^nc_api_loose.png"

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
					loose.tiles[k] = nodecore.underride({
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
		loose.groups.loose_repack = 1

		if loose.groups.crumbly and not loose.no_repack then
			minetest.after(0, function()
					nodecore.register_craft({
							label = "repack " .. loose.name,
							action = "pummel",
							indexkeys = {loose.name},
							nodes = {
								{match = loose.name, replace = name}
							},
							toolgroups = {thumpy = loose.repack_level or 1},
						})
				end)
		end

		local solid = nodecore.underride(def.alternate_solid or {}, def)
		solid.drop_in_place = loose.name
		loose.drop_in_place = nil

		loose.alternate_loose = nil
		loose.alternate_solid = nil
		loose.repack_to = name
		minetest.register_node(loose.name, loose)

		solid.alternate_loose = nil
		solid.alternate_solid = nil
		minetest.register_node(name, solid)

		return true
	end)

nodecore.register_soaking_abm({
		label = "loose self-repack",
		fieldname = "repack",
		nodenames = {"group:loose_repack"},
		interval = 10,
		soakrate = function(pos, node)
			local def = minetest.registered_items[node.name] or {}
			if def.no_repack or def.no_self_repack then return end

			local bnode = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z})
			local bdef = minetest.registered_items[bnode.name] or {}
			if (not bdef.groups) or bdef.groups.falling_node then return false end

			local weight = 1
			for dy = 1, 8 do
				local n = minetest.get_node({x = pos.x, y = pos.y + dy, z = pos.z})
				local ddef = minetest.registered_items[n.name] or {}
				if ddef and ddef.groups and ddef.groups.falling_node then
					local w = ddef.crush_damage or 1
					if w < 1 then w = 1 end
					weight = weight + w
				elseif ddef and ddef.liquidtype and ddef.liquidtype ~= "none" then
					weight = weight + 1
				end
			end
			return weight * 2 / math_pow(2, def.repack_level or 1)
		end,
		soakcheck = function(data, pos, node)
			if data.total < 100 then return end
			local def = minetest.registered_items[node.name] or {}
			return nodecore.swap_loud(pos, {name = def.repack_to})
		end
	})

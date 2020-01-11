-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore
    = math, minetest, nodecore
local math_floor, math_sqrt
    = math.floor, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

nodecore.hard_stone_strata = 7

function nodecore.hard_stone_tile(n)
	local o = math_floor(math_sqrt(n or 0) * 96)
	if o <= 0 then
		return modname .. "_stone.png"
	end
	if o >= 255 then
		return modname .. "_stone.png^"
		.. modname .. "_stone_hard.png"
	end
	return modname .. "_stone.png^("
	.. modname .. "_stone_hard.png^[opacity:"
	.. o .. ")"
end

function nodecore.register_dirt_leeching(fromnode, tonode, rate)
	local function waterat(pos, dx, dy, dz)
		pos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
		local node = minetest.get_node(pos)
		return minetest.get_item_group(node.name, "water") ~= 0
	end
	nodecore.register_soaking_abm({
			label = fromnode .. " leeching to " .. tonode,
			fieldname = "leech",
			nodenames = {fromnode},
			neighbors = {"group:water"},
			interval = 5,
			chance = 1,
			soakrate = function(pos)
				if not waterat(pos, 0, 1, 0) then return false end
				local qty = 1
				if waterat(pos, 1, 0, 0) then qty = qty * 1.5 end
				if waterat(pos, -1, 0, 0) then qty = qty * 1.5 end
				if waterat(pos, 0, 0, 1) then qty = qty * 1.5 end
				if waterat(pos, 0, 0, -1) then qty = qty * 1.5 end
				if waterat(pos, 0, -1, 0) then qty = qty * 1.5 end
				return qty * (rate or 1)
			end,
			soakcheck = function(data, pos)
				if data.total < 5000 then return end
				minetest.set_node(pos, {name = tonode})
				nodecore.node_sound(pos, "place")
				return nodecore.fallcheck(pos)
			end
		})
end

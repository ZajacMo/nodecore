-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore
    = minetest, nodecore
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local flame = {groups = {flame = true}}
local function heated(pos)
	if nodecore.quenched(pos) then return end
	local f = 0
	if nodecore.match({x = pos.x + 1, y = pos.y, z = pos.z}, flame)
	then f = f + 1 end
	if nodecore.match({x = pos.x - 1, y = pos.y, z = pos.z}, flame)
	then f = f + 1 end
	if nodecore.match({x = pos.x, y = pos.y, z = pos.z + 1}, flame)
	then f = f + 1 end
	if f >= 3 then return true end
	if nodecore.match({x = pos.x, y = pos.y, z = pos.z - 1}, flame)
	then f = f + 1 end
	if f >= 3 then return true end
end

local function timecounter(meta, max, check)
	if not check then
		local t = meta:to_table()
		t.fields.glasscook = nil
		meta:from_table(t)
		return
	end
	local t = (meta:get_int("glasscook") or 0) + 1
	if t >= max then return true end
	meta:set_int("glasscook", t)
end

nodecore.register_limited_abm({
		label = "Melt Sand",
		interval = 1,
		chance = 1,
		nodenames = {"nc_terrain:sand_loose"},
		neighbors = {"group:flame"},
		action = function(pos, node)
			if timecounter(minetest:get_meta(pos), 20, heated(pos)) then
				minetest:get_meta(pos):from_table({})
				return minetest.set_node(pos, {name = modname .. ":glass_hot_source"})
			end
		end})

local src = modname .. ":glass_hot_source"
local flow = modname .. ":glass_hot_flowing"
nodecore.register_limited_abm({
		label = "Molten Glass Flowing/Casting",
		interval = 2,
		chance = 2,
		nodenames = {src},
		action = function(pos, node)
			local miny = pos.y - 1
			local found = {}
			nodecore.scan_flood(pos, 5, function(p)
					local nn = minetest.get_node(p).name
					if nn == src then return end
					if nn ~= flow then return false end
					if p.y > miny then return end
					if p.y == miny then
						found[#found + 1] = p
						return
					end
					miny = p.y
					found = {p}
				end)
			if #found > 0 then
				local np = nodecore.pickrand(found)
				minetest.set_node(np, node)
				return minetest.set_node(pos, {name = flow, param2 = 7})
			end

			if #minetest.find_nodes_in_area(
				{x = pos.x - 1, y = pos.y - 1, z = pos.z - 1},
				{x = pos.x + 1, y = pos.y + 1, z = pos.z + 1},
				{flow}) > 0 then return end

			if nodecore.quenched(pos) then
				return minetest.set_node(pos, {name = modname .. ":glass_opaque"})
			end

			if timecounter(minetest.get_meta(pos), 30, not heated(pos)) then
				minetest.get_meta(pos):from_table({})
				return minetest.set_node(pos, {name = modname .. ":glass"})
			end
		end})

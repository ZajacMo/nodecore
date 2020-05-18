-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_floor, math_random
    = math.floor, math.random
-- LUALOCALS > ---------------------------------------------------------

local cache = {}

function nodecore.item_ent_merge(pos)
	if not pos then return end
	pos = vector.round(pos)
	local hash = minetest.hash_node_position(pos)

	local t = cache[hash]
	if t and t > nodecore.gametime then return end
	cache[hash] = (t or nodecore.gametime) + 0.75 + 0.5 * math_random()

	local db = {}
	for _, obj in pairs(nodecore.get_objects_at_pos(pos, 1)) do
		local lua = obj.get_luaentity and obj:get_luaentity()
		if lua and lua.name == "__builtin:item" then
			local stack = ItemStack(lua.itemstring or "")
			if not stack:is_empty() then
				local qty = stack:get_count()
				stack:set_count(1)
				local key = stack:to_string()
				local entry = db[key]
				if entry then
					entry.qty = entry.qty + qty
					entry.objs[#entry.objs + 1] = {obj = obj, lua = lua}
				else
					db[key] = {
						stack = stack,
						qty = qty,
						objs = {{obj = obj, lua = lua}}
					}
				end
			end
		end
	end
	for _, entry in pairs(db) do
		if #entry.objs > 1 then
			local stack = entry.stack
			local qty = entry.qty
			local max = stack:get_stack_max()
			local stax = math_floor((qty + max - 1) / max)
			if stax < #entry.objs then
				for _, item in pairs(entry.objs) do
					if qty > 0 then
						local num = qty > max and max or qty
						stack:set_count(num)
						item.lua:set_item(stack)
						qty = qty - num
					else
						item.obj:remove()
					end
				end
			end
		end
	end
end

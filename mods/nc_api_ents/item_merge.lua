-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, vector
    = ItemStack, minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local function addtodict(dict, key, item)
	local entry = dict[key]
	if not entry then
		entry = {}
		dict[key] = entry
	end
	entry[#entry + 1] = item
end

local function removesingles(dict)
	local t = {}
	for k, v in pairs(dict) do
		if #v > 1 then t[k] = v end
	end
	return t
end

minetest.register_globalstep(function()
		local gethash = minetest.hash_node_position
		local round = vector.round

		local dict = {}
		for _, ent in pairs(minetest.luaentities) do
			if ent.name == "__builtin:item" then
				local pos = ent.object:get_pos()
				if pos then addtodict(dict, gethash(round(pos)), ent) end
			end
		end
		dict = removesingles(dict)

		for _, ents in pairs(dict) do
			local groups = {}
			for _, ent in pairs(ents) do
				addtodict(groups, nodecore.stack_family(ent.itemstring), ent)
			end
			groups = removesingles(groups)
			for _, grp in pairs(groups) do
				local max = ItemStack(grp[1].itemstring):get_stack_max()
				local stacks = {}
				local partial
				local pqty = 0
				for _, ent in pairs(grp) do
					if not partial then
						partial = ItemStack(ent.itemstring)
						pqty = partial:get_count()
						partial:set_count(max)
					else
						pqty = pqty + ItemStack(ent.itemstring):get_count()
						if pqty >= max then
							stacks[#stacks + 1] = partial
							partial = ItemStack(partial)
							pqty = pqty - max
						end
					end
				end
				if pqty > 0 then
					partial:set_count(pqty)
					stacks[#stacks + 1] = partial
				end
				for i = 1, #grp do
					local stack = stacks[i]
					if stack then
						grp[i].itemstring = stack:to_string()
					else
						grp[i].object:remove()
					end
				end
			end
		end
	end)

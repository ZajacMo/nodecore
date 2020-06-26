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
				local newpos = {x = 0, y = 0, z = 0}
				local newvel = {x = 0, y = 0, z = 0}
				local samples = 0
				local max = ItemStack(grp[1].itemstring):get_stack_max()
				local stacks = {}
				local partial
				local pqty = 0
				for _, ent in pairs(grp) do
					local stack = ItemStack(ent.itemstring)
					local iqty = stack:get_count()
					newpos = vector.add(newpos, vector.multiply(
							ent.object:get_pos(), iqty))
					newvel = vector.add(newvel, vector.multiply(
							ent.object:get_velocity(), iqty))
					samples = samples + iqty
					if not partial then
						pqty = stack:get_count()
						stack:set_count(max)
						partial = stack:to_string()
					else
						pqty = pqty + iqty
						while pqty >= max do
							stacks[#stacks + 1] = partial
							pqty = pqty - max
						end
					end
				end
				if pqty > 0 then
					partial = ItemStack(partial)
					partial:set_count(pqty)
					stacks[#stacks + 1] = partial:to_string()
				end
				newpos = vector.multiply(newpos, 1 / samples)
				newvel = vector.multiply(newvel, 1 / samples)
				for i = 1, #grp do
					local stack = stacks[i]
					local ent = grp[i]
					if stack then
						ent.itemstring = stack
						ent.object:set_pos(newpos)
						ent.object:set_velocity(newvel)
					else
						ent.itemstring = ""
						ent.object:remove()
					end
				end
			end
		end
	end)

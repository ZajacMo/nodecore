-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs
    = ItemStack, minetest, nodecore, pairs
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_aism({
		label = "Packed Tote AISMs",
		interval = 1,
		chance = 1,
		itemnames = {"group:tote"},
		action = function(stack, data)
			local stackmeta = stack:get_meta()
			local raw = stackmeta:get_string("carrying")
			local inv = raw and (raw ~= "") and minetest.deserialize(raw)
			if not inv then return end

			local dirty
			for _, slot in pairs(inv) do
				-- Modern format
				if slot and slot.m and slot.m.fields and slot.m.fields.ncitem then
					local istack = ItemStack(slot.m.fields.ncitem)
					local sdata = {
						pos = data.pos,
						toteslot = slot,
						set = function(s)
							slot.m.fields.ncitem = s:to_string()
							dirty = true
						end
					}
					if not istack:is_empty() then
						nodecore.aism_check_stack(istack, sdata)
					end
				end
				-- Legacy format
				for lname, list in pairs(slot and slot.m and slot.m.inventory or {}) do
					for sub, item in pairs(list) do
						local istack = ItemStack(item)
						local sdata = {
							pos = data.pos,
							toteslot = slot,
							totelistname = lname,
							totelist = list,
							totesubslot = sub,
							set = function(s)
								list[sub] = s:to_string()
								dirty = true
							end
						}
						if not istack:is_empty() then
							nodecore.aism_check_stack(istack, sdata)
						end
					end
				end
			end
			if not dirty then return end

			stackmeta:set_string("carrying", minetest.serialize(inv))
			return stack
		end
	})

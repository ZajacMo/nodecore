-- LUALOCALS < ---------------------------------------------------------
local ItemStack, core, nc, pairs
    = ItemStack, core, nc, pairs
-- LUALOCALS > ---------------------------------------------------------

nc.register_aism({
		label = "Packed Tote AISMs",
		interval = 1,
		chance = 1,
		itemnames = {"group:tote"},
		action = function(stack, data)
			local stackmeta = stack:get_meta()
			local raw = stackmeta:get_string("carrying")
			local inv = raw and (raw ~= "") and core.deserialize(raw)
			if not inv then return end

			local dirty
			for _, slot in pairs(inv) do
				-- Modern format
				local ncitem = slot and slot.m and slot.m.fields
				and slot.m.fields.ncitem
				if ncitem then
					local istack = ItemStack(ncitem)
					if not istack:is_empty() then
						local sdata = {
							pos = data.pos,
							toteslot = slot,
							set = function(s)
								local ss = s:to_string()
								if ss ~= ncitem then
									slot.m.fields.ncitem = ss
									dirty = true
								end
							end
						}
						nc.aism_check_stack(istack, sdata)
					end
				end
				-- Legacy format
				for lname, list in pairs(slot and slot.m and slot.m.inventory or {}) do
					for sub, item in pairs(list) do
						local istack = ItemStack(item)
						if not istack:is_empty() then
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
							nc.aism_check_stack(istack, sdata)
						end
					end
				end
			end
			if not dirty then return end

			stackmeta:set_string("carrying", core.serialize(inv))
			return stack
		end
	})

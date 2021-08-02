-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_ceil, math_exp, math_log
    = math.ceil, math.exp, math.log
-- LUALOCALS > ---------------------------------------------------------

minetest.after(0, function()
		local convert = {}
		local charge = {}

		local boost = {}
		local unboost = {}

		local function altcheck(k, v, t, f)
			if v[f] and v[f] ~= k and minetest.registered_items[v[f]] then
				t[k] = v[f]
			end
		end
		for k, v in pairs(minetest.registered_items) do
			altcheck(k, v, convert, "alternative_lux_infused")
			altcheck(k, v, boost, "alternative_lux_boosted")
			altcheck(k, v, unboost, "alternative_lux_unboosted")
			if v.groups and v.groups.lux_tool then
				charge[k] = true
			end
		end

		local function listjoin(a, b)
			local t = {}
			for k in pairs(a) do t[#t + 1] = k end
			for k in pairs(b) do if not a[k] then t[#t + 1] = k end end
			return t
		end
		local allinfuse = listjoin(convert, charge)
		local allboost = listjoin(boost, unboost)

		local ratefactor = 20000
		nodecore.register_soaking_aism({
				label = "lux infuse",
				fieldname = "infuse",
				interval = 2,
				itemnames = allinfuse,
				soakrate = function(stack, aismdata)
					local name = stack:get_name()
					if (not charge[name]) and (not convert[name]) then return false end

					local pos = aismdata.pos or aismdata.player and aismdata.player:get_pos()
					return nodecore.lux_soak_rate(pos)
				end,
				soakcheck = function(data, stack)
					local name = stack:get_name()
					if convert[name] and stack:get_wear() < 3277 then
						stack = ItemStack(convert[name])
						stack:set_wear(65535)
						return data.total, stack
					end
					if not charge[name] then return data.total, stack end
					local wear = stack:get_wear()
					local newear = math_ceil(wear * math_exp(-data.total / ratefactor))
					if newear == wear then return data.total, stack end
					if newear < 1 then return 1 end
					local used = math_log(wear / newear) * ratefactor
					stack:set_wear(newear)
					return data.total - used, stack
				end
			})

		nodecore.register_aism({
				label = "lux boost",
				interval = 2,
				chance = 1,
				itemnames = allboost,
				action = function(stack, data)
					local name = stack:get_name()
					local need = #nodecore.find_nodes_around(data.pos, "group:lux_fluid", 2) > 0
					local newname = (need and boost or unboost)[name] or name
					if newname == name then return end
					stack:set_name(newname)
					return stack
				end
			})
	end)

nodecore.register_aism({
		label = "lux diffuse in water",
		interval = 2,
		chance = 1,
		itemnames = {"group:lux_tool"},
		action = function(stack, data)
			if not data.pos then return end
			local qty = #nodecore.find_nodes_around(data.pos, "group:water")
			if qty < 1 then return end
			if data.player then
				qty = qty * (1 + vector.length(
						data.player:get_player_velocity()) / 5)
			end
			local dur = 65535 - stack:get_wear()
			dur = dur * 0.9998 ^ qty
			stack:set_wear(65535 - dur)
			return stack
		end
	})

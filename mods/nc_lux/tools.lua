-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_ceil, math_exp, math_log
    = math.ceil, math.exp, math.log
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local convert = {}
local charge = {}

local boost_suff = "_boost"

local function mktool(tshape, buffs)
	buffs = buffs or {}
	for _, temper in pairs({"tempered", "annealed"}) do
		local orig = minetest.registered_items["nc_lode:" .. tshape .. "_" .. temper]

		local def = nodecore.underride({
				description = "Infused " .. orig.description,
				inventory_image = orig.inventory_image .. "^(" .. modname
				.. "_base.png^[mask:" .. modname
				.. "_infuse_mask.png^[mask:nc_lode_" .. tshape
				.. ".png^[opacity:80])",
				tool_wears_to = orig.name,
				glow = 1
			}, orig)
		def.after_use = nil

		def.groups = nodecore.underride({lux_tool = 1, lux_emit = 1}, orig.groups or {})
		local tc = {}
		for k, v in pairs(orig.tool_capabilities.opts) do
			tc[k] = v + 1 + (buffs[k] or 0)
		end
		tc.uses = 0.125
		def.tool_capabilities = nodecore.toolcaps(tc)
		if def.on_rake then
			def.on_rake = nodecore.lode_rake_function(def.tool_capabilities)
		end

		for k, v in pairs(orig.tool_capabilities.opts) do
			tc[k] = v + 2 + (buffs[k] or 0)
		end
		local boosttc = nodecore.toolcaps(tc)
		local boost = nodecore.underride({
				inventory_image = orig.inventory_image .. "^(" .. modname
				.. "_base.png^[mask:" .. modname
				.. "_infuse_mask.png^[mask:nc_lode_" .. tshape
				.. ".png^[opacity:120])",
				tool_capabilities = boosttc,
				glow = 2,
				light_source = 1,
				on_rake = def.on_rake and nodecore.lode_rake_function(boosttc)
			}, def)

		boost.groups = nodecore.underride({lux_tool = 1, lux_emit = 2}, def.groups)

		def.name = modname .. ":" .. tshape .. "_" .. temper
		minetest.register_tool(def.name, def)

		boost.name = modname .. ":" .. tshape .. "_" .. temper .. boost_suff
		minetest.register_tool(boost.name, boost)

		convert[orig.name] = def.name
		charge[def.name] = true
		charge[boost.name] = true
	end
end
for _, shape in pairs({"mallet", "spade", "hatchet", "pick", "mattock"}) do
	mktool("tool_" .. shape)
end
mktool("adze")
mktool("rake", {crumbly = 3})

local alltools = {}
for k in pairs(convert) do alltools[#alltools + 1] = k end
for k in pairs(charge) do
	if not convert[k] then
		alltools[#alltools + 1] = k
	end
end

local ratefactor = 20000
nodecore.register_soaking_aism({
		label = "lux infuse",
		fieldname = "infuse",
		interval = 2,
		chance = 1,
		itemnames = alltools,
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
		itemnames = {"group:lux_tool"},
		action = function(stack, data)
			local name = stack:get_name()
			local boosted = name:sub(-#boost_suff) == boost_suff
			local boost = #nodecore.find_nodes_around(data.pos, "group:lux_fluid", 2) > 0
			if boost == boosted then return end

			if boost and not boosted then
				name = name .. boost_suff
			else
				name = name:sub(1, -1 - #boost_suff)
			end
			stack:set_name(name)
			return stack
		end
	})

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

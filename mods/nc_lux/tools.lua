-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_floor, math_pow
    = math.floor, math.pow
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local convert = {}
local charge = {}

for _, shape in pairs({'mallet', 'spade', 'hatchet', 'pick', 'mattock'}) do
	for _, temper in pairs({'tempered', 'annealed'}) do
		local orig = minetest.registered_items["nc_lode:tool_" .. shape .. "_" .. temper]

		local def = nodecore.underride({
				description = "Infused " .. orig.description,
				inventory_image = orig.inventory_image .. "^(" .. modname
				.. "_base.png^[mask:nc_lode_tool_" .. shape .. ".png^[opacity:64])",
				tool_wears_to = orig.name
			}, orig)
		def.after_use = nil

		local tc = {}
		for k, v in pairs(orig.tool_capabilities.opts) do
			tc[k] = v + 1
		end
		tc.uses = 0.5
		def.tool_capabilities = nodecore.toolcaps(tc)

		def.name = modname .. ":tool_" .. shape .. "_" .. temper
		minetest.register_tool(def.name, def)

		convert[orig.name] = def.name
		charge[def.name] = true
	end
end

local function isfluid(pos)
	local def = minetest.registered_nodes[minetest.get_node(pos).name]
	return def and def.groups and def.groups.lux_fluid
end
local indirs = {}
for _, v in pairs(nodecore.dirs()) do
	if v.y == 0 then
		indirs[#indirs + 1] = v
	end
end
nodecore.register_soaking_abm({
		label = "Lux Infusion",
		interval = 2,
		chance = 1,
		nodenames = {"nc_items:stack"},
		neighbors = {"group:lux_fluid"},
		soakrate = function(pos)
			local stack = nodecore.stack_get(pos)
			local name = stack:get_name()
			if (not charge[name]) and (not convert[name]) then return false end

			local above = vector.add(pos, {x = 0, y = 1, z = 0})
			if not isfluid(above) then return false end
			local qty = 1
			for _, v in pairs(indirs) do
				if isfluid(vector.add(pos, v)) then qty = qty + 1 end
			end

			local dist = nodecore.scan_flood(above, 14, function(p, d)
					if p.dir and p.dir.y < 0 then return false end
					local nn = minetest.get_node(p).name
					if nn == modname .. ":flux_source" then return d end
					if nn ~= modname .. ":flux_flowing" then return false end
				end)
			if not dist then return false end

			return qty * 20 / math_pow(2, dist / 2)
		end,
		soakcheck = function(data, pos)
			local stack = nodecore.stack_get(pos)
			local name = stack:get_name()
			local dw = math_floor(data.total)
			if charge[name] then
				stack:add_wear(-dw)
				nodecore.stack_set(pos, stack)
			elseif convert[name] and stack:get_wear() < 3277 then
				stack = ItemStack(convert[name])
				stack:set_wear(65535 - dw)
				nodecore.stack_set(pos, stack)
			end
			return data.total - dw
		end
	})

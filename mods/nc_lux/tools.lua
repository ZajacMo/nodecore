-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, pairs, vector
    = ItemStack, minetest, nodecore, pairs, vector
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
nodecore.register_limited_abm({
		label = "Lux Infusion",
		interval = 1,
		chance = 2,
		nodenames = {"nc_items:stack"},
		neighbors = {"group:lux_fluid"},
		action = function(pos)
			local stack = nodecore.stack_get(pos)
			local name = stack:get_name()
			local above = vector.add(pos, {x = 0, y = 1, z = 0})
			if not isfluid(above) then return end
			local qty = 1
			for _, v in pairs(indirs) do
				if isfluid(vector.add(pos, v)) then qty = qty + 1 end
			end
			if charge[name] then
				stack:add_wear(-qty * 20)
				nodecore.stack_set(pos, stack)
			elseif convert[name] and stack:get_wear() < 3277 then
				stack = ItemStack(convert[name])
				stack:set_wear(65535)
				nodecore.stack_set(pos, stack)
			end
		end
	})

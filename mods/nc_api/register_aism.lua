-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs
    = math, minetest, nodecore, pairs
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

-- Active ItemStack Modifiers

-- Definition:
--- itemnames: {"mod:itemname", "group:name"}
--- interval: integer,
--- chance: integer,
--- func: function(stack, data) end
-- Data:
--- {pos, node}
--- {player, inv, list, slot}

nodecore.register_aism,
nodecore.registered_aisms
= nodecore.mkreg()

local aismidx = {}
minetest.after(0, function()
		for _, def in pairs(nodecore.registered_aisms) do
			for _, name in pairs(def.itemnames) do
				if name:sub(1, 6) == "group:" then
					for k, v in pairs(minetest.registered_items) do
						if v and v.groups and v.groups[name:sub(7)] then
							aismidx[k] = aismidx[k] or {}
							aismidx[k][#aismidx[k] + 1] = def
						end
					end
				else
					aismidx[name] = aismidx[name] or {}
					aismidx[name][#aismidx[name] + 1] = def
				end
			end
		end
	end)

local function checkrun(def, stack, data)
	if def.chance and def.chance > 1 and math_random(1, def.chance) ~= 1 then return end
	if def.interval and def.interval > 1 and (minetest.get_gametime() % def.interval) ~= 0 then return end
	return def(stack, data)
end

local function checkstack(stack, data)
	if (not stack) or stack:is_empty() then return end
	local name = stack:get_name()
	local defs = aismidx[name]
	if not defs then return end
	for _, def in pairs(defs) do
		checkrun(def, stack, data)
	end
end

nodecore.register_limited_abm({
		label = "AISM Scheduler",
		nodenames = {"group:visinv"},
		interval = 1,
		chance = 1,
		action = function(pos, node)
			return checkstack(nodecore.stack_get(pos), {
					pos = pos,
					node = node
				})
		end
	})

local function invtick()
	minetest.after(1, invtick)
	for _, player in pairs(minetest.get_connected_players()) do
		local inv = player:get_inventory()
		for lname, list in pairs(inv:get_lists()) do
			for slot, stack in pairs(list) do
				checkstack(stack, {
						player = player,
						inv = inv,
						list = lname,
						slot = slot
					})
			end
		end
	end
end
invtick()

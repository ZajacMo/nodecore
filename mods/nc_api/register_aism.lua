-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, string
    = math, minetest, nodecore, pairs, string
local math_random, string_format
    = math.random, string.format
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
local function defadd(key, def)
	aismidx[key] = aismidx[key] or {}
	aismidx[key][def] = true
end
minetest.after(0, function()
		for _, def in pairs(nodecore.registered_aisms) do
			for _, name in pairs(def.itemnames) do
				if name:sub(1, 6) == "group:" then
					for k, v in pairs(minetest.registered_items) do
						if v and v.groups and v.groups[name:sub(7)] then
							defadd(k, def)
						end
					end
				else
					defadd(name, def)
				end
			end
		end
		local keys = 0
		local defs = 0
		local peak = 0
		for _, v in pairs(aismidx) do
			keys = keys + 1
			local n = 0
			for _ in pairs(v) do n = n + 1 end
			defs = defs + n
			if n > peak then peak = n end
		end
		minetest.log(string_format("register_aism: %d keys, %d defs, %d peak", keys, defs, peak))
	end)

local function checkrun(def, stack, data)
	if def.chance and def.chance > 1 and math_random(1, def.chance) ~= 1 then return end
	if def.interval and def.interval > 1 and (minetest.get_gametime() % def.interval) ~= 0 then return end
	stack = def.action(stack, data)
	if stack then
		if data.node then
			nodecore.stack_set(data.pos, stack)
		elseif data.inv and data.list and data.slot then
			data.inv:set_stack(data.list, data.slot, stack)
		end
	end
end

local function checkstack(stack, data)
	if (not stack) or stack:is_empty() then return end
	local name = stack:get_name()
	local defs = aismidx[name]
	if not defs then return end
	for def in pairs(defs) do
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
		local pos = player:get_pos()
		pos.y = pos.y + player:get_properties().eye_height
		local inv = player:get_inventory()
		for lname, list in pairs(inv:get_lists()) do
			for slot, stack in pairs(list) do
				checkstack(stack, {
						pos = pos,
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

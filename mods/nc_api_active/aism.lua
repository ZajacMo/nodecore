-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs
    = ItemStack, math, minetest, nodecore, pairs
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

-- Active ItemStack Modifiers

-- Definition:
--- itemnames: {"mod:itemname", "group:name"}
--- interval: integer,
--- chance: integer,
--- action: function(stack, data) end,
--- arealoaded: this distance around must be loaded
-- Data:
--- {pos, node}
--- {player, inv, list, slot}

nodecore.register_aism,
nodecore.registered_aisms
= nodecore.mkreg()

local aismidx, idxrebuild = nodecore.item_matching_index(
	nodecore.registered_aisms,
	function(i) return i.itemnames end,
	"register_aism"
)

do
	local pending
	local oldreg = nodecore.register_aism
	local function helper(...)
		if pending then return ... end
		pending = true
		minetest.after(0, function()
				pending = nil
				return idxrebuild()
			end)
		return ...
	end
	nodecore.register_aism = function(...)
		return helper(oldreg(...))
	end
end

local function checkrun(def, stack, data)
	if nodecore.stasis and not def.ignore_stasis then return end
	if def.chance and def.chance > 1 and math_random(1, def.chance) ~= 1 then return end
	if def.interval and def.interval > 1 and (minetest.get_gametime()
		% def.interval) ~= 0 then return end
	if def.arealoaded and nodecore.near_unloaded(data.pos, nil, def.arealoaded) then return end
	stack = def.action(stack, data)
	if stack and data.set then data.set(ItemStack(stack)) end
end

local function checkstack(stack, data)
	local defs = aismidx[stack:get_name()]
	if not defs then return end
	for def in pairs(defs) do
		checkrun(def, stack, data)
	end
end
nodecore.aism_check_stack = checkstack

minetest.register_abm({
		label = "aism schedule",
		nodenames = {"group:visinv"},
		interval = 1,
		chance = 1,
		ignore_stasis = true,
		action = function(pos, node)
			return checkstack(nodecore.stack_get(pos), {
					pos = pos,
					node = node,
					set = function(s)
						return nodecore.stack_set(pos, s)
					end
				})
		end
	})

nodecore.interval(1, function()
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
							slot = slot,
							set = function(s)
								return inv:set_stack(lname, slot, s)
							end
						})
				end
			end
		end
	end)

nodecore.register_item_entity_step(function(self, dtime)
		local t = (self.aismtimer or 0) + dtime
		while t >= 1 do
			t = t - 1
			local pos = self.object:get_pos()
			if not pos then return end
			local setstack
			checkstack(ItemStack(self.itemstring), {
					pos = pos,
					obj = self.object,
					ent = self,
					set = function(s) setstack = s end
				})
			if setstack then
				if setstack:is_empty() then
					return self.object:remove()
				end
				self.itemstring = setstack:to_string()
			end
		end
		self.aismtimer = t
	end)

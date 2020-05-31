-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, vector
    = math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

--[[
Helpers for visible inventory. Use "visinv" node group.
Sets up on_construct, after_destruct and an ABM to manage
the visual entities.
--]]

local modname = minetest.get_current_modname()

------------------------------------------------------------------------
-- VISIBLE STACK ENTITY

local function getlightcheck(rp, obj, src)
	return function()
		local stack = nodecore.stack_get(rp)
		if not stack or stack:is_empty() then return end

		local def = minetest.registered_items[stack:get_name()] or {}
		if (def.light_source or 0) ~= src then return end

		for _, v in pairs(nodecore.get_objects_at_pos(rp)) do
			if v == obj then return true end
		end
	end
end

minetest.register_entity(modname .. ":stackent", {
		initial_properties = nodecore.stackentprops(),
		is_stack = true,
		itemcheck = function(self)
			self.cktime = math_random() + 0.5

			local obj = self.object
			local pos = obj:get_pos()
			if not pos then return end

			local stack = nodecore.stack_get(pos)
			if not stack or stack:is_empty() then return obj:remove() end

			local rp = vector.round(pos)
			local def = minetest.registered_items[stack:get_name()] or {}
			local src = def.light_source or 0
			if src > 0 then
				self.light_source = src
				nodecore.dynamic_light_add(rp, src, getlightcheck(rp, obj, src))
			end

			local props, scale, yaw = nodecore.stackentprops(stack,
				rp.x * 3 + rp.y * 5 + rp.z * 7)
			rp.y = rp.y + scale - 31/64

			obj:set_properties(props)
			if obj:get_yaw() ~= yaw then
				obj:set_yaw(yaw)
			end
			if not vector.equals(obj:get_pos(), rp) then
				obj:set_pos(rp)
			end
		end,
		on_activate = function(self)
			return self:itemcheck()
		end,
		on_step = function(self, dtime)
			self.cktime = (self.cktime or 0) - dtime
			if self.cktime > 0 then return end
			return self:itemcheck()
		end
	})

local visenv_ent_check = {}

minetest.register_globalstep(function()
		for _, e in pairs(minetest.luaentities) do
			if e.is_stack then
				local pos = e.object:get_pos()
				if pos then
					local key = minetest.hash_node_position(vector.round(pos))
					local max = visenv_ent_check[key]
					if max then
						if max < 1 then
							e.object:remove()
						else
							visenv_ent_check[key] = max - 1
						end
					end
				end
			end
		end
		for k, v in pairs(visenv_ent_check) do
			if v > 0 then
				local pos = minetest.get_position_from_hash(k)
				minetest.add_entity(pos, modname .. ":stackent")
			end
		end
		visenv_ent_check = {}
	end)

function nodecore.visinv_update_ents(pos, node)
	pos = vector.round(pos)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	local max = def.groups and def.groups.visinv and 1 or 0
	if nodecore.stack_get(pos):is_empty() then max = 0 end
	visenv_ent_check[minetest.hash_node_position(pos)] = max
end

------------------------------------------------------------------------
-- NODE REGISTRATION HELPERS

function nodecore.visinv_on_construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("solo", 1)
	nodecore.visinv_update_ents(pos)
end

function nodecore.visinv_after_destruct(pos)
	nodecore.visinv_update_ents(pos)
	nodecore.fallcheck(pos)
end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end

		def.groups = def.groups or {}

		if def.groups.visinv then
			def.on_construct = def.on_construct or nodecore.visinv_on_construct
			def.after_destruct = def.after_destruct or nodecore.visinv_after_destruct
		end
	end)

nodecore.register_limited_abm({
		label = "VisInv Check",
		nodenames = {"group:visinv"},
		interval = 1,
		chance = 1,
		ignore_stasis = true,
		action = function(...) return nodecore.visinv_update_ents(...) end
	})

------------------------------------------------------------------------
-- DIG INVENTORY

local digpos
local old_node_dig = minetest.node_dig
minetest.node_dig = function(pos, ...)
	nodecore.stack_sounds(pos, "dug")
	local function helper(...)
		digpos = nil
		return ...
	end
	digpos = pos
	return helper(old_node_dig(pos, ...))
end
local old_get_node_drops = minetest.get_node_drops
minetest.get_node_drops = function(...)
	local drops = old_get_node_drops(...)
	if not digpos then return drops end
	drops = drops or {}
	local stack = nodecore.stack_get(digpos)
	if stack and not stack:is_empty() then
		drops[#drops + 1] = stack
	end
	return drops
end

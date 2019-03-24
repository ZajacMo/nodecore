-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, type, vector
    = math, minetest, nodecore, pairs, type, vector
local math_floor, math_pi
    = math.floor, math.pi
-- LUALOCALS > ---------------------------------------------------------

--[[
Helpers for visible inventory.  Use "visinv" node group.
Sets up on_construct, after_destruct and an ABM to manage
the visual entities.
--]]

local modname = minetest.get_current_modname()

------------------------------------------------------------------------
-- VISIBLE STACK ENTITY

local function stackentprops(stack, func)
	local t = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4 },
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
		static_save = false
	}
	if stack then
		t.is_visible = true
		t.textures[1] = stack:get_name()
		local s = 0.2 + 0.1 * stack:get_count() / stack:get_stack_max()      
		t.visual_size = {x = s, y = s}
		local max = stack:get_stack_max()
		if func then func(s) end
	end
	return t
end

minetest.register_entity(modname .. ":stackent", {
		initial_properties = stackentprops(),
		is_stack = true,
		itemcheck = function(self)
			local pos = self.object:getpos()
			local stack = nodecore.stack_get(pos)
			if not stack or stack:is_empty() then return self.object:remove() end

			local rp = vector.round(pos)
			local rot = rp.x * 3 + rp.y * 5 + rp.z * 7
			local max = stack:get_stack_max()
			local ratio = (max == 1)
			and 1 - (stack:get_wear() / 65536)
			or stack:get_count() / max
			if ratio ~= 1 then rot = rot + 1/8 + 3/8 * (1 - ratio) end
			rot = rot - 2 * math_floor(rot / 2)
			self.object:set_yaw(rot * math_pi / 2)

			return self.object:set_properties(stackentprops(stack, function(s)
						pos.y = math_floor(pos.y + 0.5) - 0.5 + s + 1/64
						self.object:setpos(pos)
					end))
		end,
		on_activate = function(self)
			self.cktime = 0.00001
		end,
		on_step = function(self, dtime)
			self.cktime = (self.cktime or 0) - dtime
			if self.cktime > 0 then return end
			self.cktime = 1
			return self:itemcheck()
		end
	})

function nodecore.visinv_update_ents(pos, node)
	node = node or minetest.get_node(pos)
	local def = minetest.registered_items[node.name] or {}
	local max = def.groups and def.groups.visinv and 1 or 0

	local found = {}
	for k, v in pairs(minetest.get_objects_inside_radius(pos, 0.5)) do
		if v and v.get_luaentity and v:get_luaentity()
		and v:get_luaentity().is_stack then
			found[#found + 1] = v
		end
	end

	if #found < max then
		minetest.add_entity(pos, modname .. ":stackent")
	else
		while #found > max do
			found[#found]:remove()
			found[#found] = nil
		end
	end
	
	return found
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
	minetest.after(0, function()
			minetest.check_for_falling(pos)
		end)
end

nodecore.register_on_register_item(function(name, def)
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
		action = function(...) return nodecore.visinv_update_ents(...) end
	})

------------------------------------------------------------------------
-- DIG INVENTORY

local digpos
local old_node_dig = minetest.node_dig
minetest.node_dig = function(pos, ...)
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

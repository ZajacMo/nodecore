-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, setmetatable, type,
      vector
    = ItemStack, math, minetest, nodecore, pairs, setmetatable, type,
      vector
local math_floor, math_pi, math_random, math_sqrt
    = math.floor, math.pi, math.random, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

--[[
Helpers for visible inventory.  Use "visinv" node group.
Sets up on_construct, after_destruct and an ABM to manage
the visual entities.
--]]

local modname = minetest.get_current_modname()

------------------------------------------------------------------------
-- VISIBLE STACK ENTITY

local function stackentprops(stack, yaw, rotate)
	local props = {
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
	local scale = 0
	yaw = yaw or 0
	if stack then
		if type(stack) == "string" then stack = ItemStack(stack) end
		props.is_visible = true
		props.textures[1] = stack:get_name()

		local ratio = stack:get_count() / stack:get_stack_max()
		scale = math_sqrt(ratio) * 0.15 + 0.25
		props.visual_size = {x = scale, y = scale}

		props.automatic_rotate = rotate
		and rotate * 2 / math_sqrt(math_sqrt(ratio)) or nil

		if ratio == 1 then ratio = 1 - (stack:get_wear() / 65536) end

		if ratio ~= 1 then yaw = yaw + 1/8 + 3/8 * (1 - ratio) end
		yaw = yaw - 2 * math_floor(yaw / 2)
	end
	return props, scale, yaw * math_pi / 2
end

minetest.register_entity(modname .. ":stackent", {
		initial_properties = stackentprops(),
		is_stack = true,
		itemcheck = function(self)
			local pos = self.object:getpos()
			local stack = nodecore.stack_get(pos)
			if not stack or stack:is_empty() then return self.object:remove() end

			local rp = vector.round(pos)
			local props, scale, yaw = stackentprops(stack,
				rp.x * 3 + rp.y * 5 + rp.z * 7)
			rp.y = rp.y + scale - 31/64

			local obj = self.object
			obj:set_properties(props)
			obj:set_yaw(yaw)
			obj:set_pos(rp)
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
-- ITEM ENT APPEARANCE

local bii = minetest.registered_entities["__builtin:item"]
local item = {
	set_item = function(self, ...)
		local realobj = self.object
		self.object = {}
		setmetatable(self.object, {
				__index = {
					set_properties = function() end
				}
			})
		bii.set_item(self, ...)
		self.object = realobj
		
		self.rotdir = self.rotdir or math_random(1, 2) * 2 - 3
		local p, s = stackentprops(self.itemstring, 0, self.rotdir)
		p.physical = true
		s = s / math_sqrt(2)
		p.collisionbox = {-s, -s, -s, s, s, s}
		return realobj:set_properties(p)
	end
}
setmetatable(item, bii)
minetest.register_entity(":__builtin:item", item)

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

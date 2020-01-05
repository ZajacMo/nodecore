-- LUALOCALS < ---------------------------------------------------------
local ItemStack, ipairs, math, minetest, nodecore, pairs, vector
    = ItemStack, ipairs, math, minetest, nodecore, pairs, vector
local math_cos, math_pi, math_random, math_sin, math_sqrt
    = math.cos, math.pi, math.random, math.sin, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

nodecore.register_item_entity_step,
nodecore.registered_item_entity_steps
= nodecore.mkreg()

nodecore.register_item_entity_on_settle,
nodecore.registered_item_entity_on_settles
= nodecore.mkreg()

local function stub() end

local data_load, data_save = nodecore.entity_staticdata_helpers({
		itemstring = true,
		spin = true,
		vel = true,
		setvel = true
	})

local function trymerge(self, peerobj)
	if self.object == peerobj then return end
	local peer = peerobj.get_luaentity and peerobj:get_luaentity()
	if (not peer) or (peer.name ~= self.name) then return end

	local mystack = ItemStack(self.itemstring)
	local myqty = mystack:get_count()
	local peerstack = ItemStack(peer.itemstring)
	local peerqty = peerstack:get_count()
	if mystack:get_free_space() < peerqty then return end

	mystack:set_count(1)
	peerstack:set_count(1)
	if mystack:to_string() ~= peerstack:to_string() then return end

	mystack:set_count(myqty + peerqty)
	self:set_item(mystack)
	peer.itemstring = ""
	local selfobj = self.object
	selfobj:set_pos(vector.multiply(vector.add(
				vector.multiply(selfobj:get_pos(), myqty),
				vector.multiply(peerobj:get_pos(), peerqty)),
			1 / (myqty + peerqty)))
	peerobj:remove()
	return true
end

local function trymergeall(self)
	local pos = self.object:get_pos()
	if not (self.oldpos and vector.equals(pos, self.oldpos)) then
		self.oldpos = pos
		return
	end

	if self.nextmerge and nodecore.gametime < self.nextmerge then return end
	self.nextmerge = (self.nextmerge or nodecore.gametime) + 0.75 + 0.5 * math_random()

	for _, obj in pairs(minetest.get_objects_inside_radius(
			self.object:get_pos(), 1)) do
		if trymerge(self, obj) then return end
	end
end

minetest.register_entity(":__builtin:item", {
		initial_properties = {
			physical = true,
			is_visible = false,
			collide_with_objects = false,
			collisionbox = {0, 0, 0, 0, 0, 0}
		},

		set_item = function(self, item)
			item = item and ItemStack(item):to_string()
			if item and item ~= self.itemstring then
				self.itemstring = item
				self.object:set_yaw(math_random() * math_pi * 2)
			end
			if nodecore.item_is_virtual(self.itemstring) then return self.object:remove() end
			self.spin = self.spin or math_random(1, 2) * 2 - 3
			local p, s = nodecore.stackentprops(self.itemstring, 0, self.spin, true)
			s = s / math_sqrt(2)
			p.collisionbox = {-s, -s, -s, s, s, s}
			p.physical = true
			return self.object:set_properties(p)
		end,

		get_staticdata = data_save,

		on_activate = function(self, data)
			self.object:set_armor_groups({immortal = 1})
			data_load(self, data)
			return self:set_item()
		end,

		on_punch = function(self, hitter)
			local inv = hitter and hitter:get_inventory()
			if inv then
				local stack = ItemStack(self.itemstring)
				stack = inv:add_item("main", stack)
				if stack:is_empty() then return self.object:remove() end
				self:set_item(stack)
			end
			local rho = math_random() * math_pi * 2
			local y = math_sin(rho)
			local xz = math_cos(rho)
			local theta = math_random() * math_pi * 2
			local x = math_cos(theta) * xz
			local z = math_sin(theta) * xz
			self.object:add_velocity(vector.multiply({x = x, y = y, z = z}, 5))
		end,

		try_merge_with = stub,

		enable_physics = stub,
		disable_physics = stub,

		settle_check = nodecore.entity_settle_check(function(self, ...)
				for _, func in ipairs(nodecore.registered_item_entity_on_settles) do
					if func(self, ...) == true then return true end
				end
				return trymergeall(self)
			end),

		on_step = function(self, dtime, ...)
			if not self.itemstring then return self.object:remove() end
			if self:settle_check() then return end

			for _, func in ipairs(nodecore.registered_item_entity_steps) do
				if func(self, dtime, ...) == true then return end
			end
		end,
	})

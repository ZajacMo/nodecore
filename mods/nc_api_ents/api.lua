-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, type, vector
    = ItemStack, math, minetest, nodecore, pairs, type, vector
local math_floor, math_pi, math_sqrt
    = math.floor, math.pi, math.sqrt
-- LUALOCALS > ---------------------------------------------------------

function minetest.spawn_falling_node(pos, node, meta)
	node = node or minetest.get_node(pos)
	if node.name == "air" or node.name == "ignore" then
		return false
	end
	local obj = minetest.add_entity(pos, "__builtin:falling_node")
	if obj then
		obj:get_luaentity():set_node(node, meta or minetest.get_meta(pos):to_table())
		minetest.remove_node(pos)
		return obj
	end
	return false
end

function nodecore.stackentprops(stack, yaw, rotate, ss)
	local props = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		visual_size = {x = 0.4, y = 0.4},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
		static_save = ss and true or false
	}
	local scale = 0
	yaw = yaw or 0
	if stack then
		if type(stack) == "string" then stack = ItemStack(stack) end
		props.is_visible = not stack:is_empty()
		props.textures[1] = stack:get_name()

		local ratio = stack:get_count() / stack:get_stack_max()
		if ratio > 1 then ratio = 1 end
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

function nodecore.entity_staticdata_helpers(savedprops)
	return function(self, data)
		data = data and minetest.deserialize(data) or {}
		for k in pairs(savedprops) do self[k] = data[k] end
	end,
	function(self)
		local data = {}
		for k in pairs(savedprops) do data[k] = self[k] end
		return minetest.serialize(data)
	end
end

local area_unloaded = {}

local function collides(_, pos)
	local node = minetest.get_node_or_nil(pos)
	if not node then return area_unloaded end
	local def = minetest.registered_nodes[node.name]
	if not def then return node end
	if def.walkable then return node end
end

function nodecore.entity_settle_check(on_settle)
	return function(self)
		local pos = self.object:get_pos()
		local bpos = {x = pos.x, y = pos.y - 0.75, z = pos.z}
		local coll = collides(self, bpos)
		if not coll then
			if self.setvel then
				self.object:set_velocity(self.vel)
				self.setvel = nil
			end
			self.vel = self.object:get_velocity()
			return nodecore.grav_air_accel_ent(self.object)
		end
		if coll == area_unloaded then
			self.object:set_pos(vector.round(self.object.bpos))
			self.object:set_velocity({x = 0, y = 0, z = 0})
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self.setvel = true
			return
		end
		pos = vector.round(pos)
		if collides(self, pos) then
			pos.y = pos.y + 1
			return self.object:set_pos(pos)
		end

		if not on_settle(self, pos) then return end

		pos.y = pos.y + 1
		for _, obj in pairs(minetest.get_objects_inside_radius(pos, 2)) do
			if vector.equals(vector.round(obj:get_pos()), pos) then
				obj = obj.get_luaentity and obj:get_luaentity()
				if obj and obj.settle_check then
					obj:settle_check()
				end
			end
		end

		return nodecore.fallcheck(pos)
	end
end

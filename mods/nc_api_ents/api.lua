-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, table, type, vector
    = ItemStack, math, minetest, nodecore, pairs, table, type, vector
local math_floor, math_pi, math_random, math_sqrt, table_insert,
      table_remove
    = math.floor, math.pi, math.random, math.sqrt, table.insert,
      table.remove
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
		and rotate * 2 / math_sqrt(math_sqrt(ratio)) or 0

		local def = minetest.registered_items[stack:get_name()]
		props.glow = def and (def.glow or def.light_source)

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

local function collides(pos)
	if pos.y < nodecore.map_limit_min then return {name = "ignore"} end
	local node = minetest.get_node_or_nil(pos)
	if not node then return area_unloaded end
	local def = minetest.registered_nodes[node.name]
	if not def then return node end
	if def.walkable or def.groups and def.groups.support_falling then return node end
end

local oldcheck = minetest.check_single_for_falling
function minetest.check_single_for_falling(...)
	local oldget = minetest.get_node_or_nil
	function minetest.get_node_or_nil(pos, ...)
		if pos.y < nodecore.map_limit_min then return end
		return oldget(pos, ...)
	end
	local function helper(...)
		minetest.get_node_or_nil = oldget
		return ...
	end
	return helper(oldcheck(...))
end

function nodecore.entity_update_maxy(self, pos, vel)
	pos = pos or self.object:get_pos()
	if not pos then return end
	if (not self.maxy) or pos.y > self.maxy then
		self.maxy = pos.y
		return
	end
	vel = vel or self.object:get_velocity()
	if vel.y > 0 then self.maxy = pos.y end
end

local hash_node_position = minetest.hash_node_position
local round = vector.round
local function yqinsert(yq, ent)
	local key = ent.maxy

	local grp = yq.ents[key]
	if not grp then
		grp = {}
		yq.ents[key] = grp

		local min = 1
		local max = #yq.idx
		while max > min do
			local try = math_floor((min + max) / 2)
			if key > yq.idx[try] then
				min = try + 1
			else
				max = try
			end
		end
		table_insert(yq.idx, min, key)
	end
	grp[#grp + 1] = ent
end
local function yqinsertall(yq, bypos, pos)
	local key = hash_node_position(pos)
	local list = bypos[key]
	if not list then return end
	bypos[key] = nil
	for e in pairs(list) do
		yqinsert(yq, e)
	end
end
local entity_settle_recursing
function nodecore.entity_settle_recurse(pos)
	if entity_settle_recursing then return end
	entity_settle_recursing = true
	pos = round(pos)
	local blocked = {[hash_node_position(pos)] = true}
	local bypos = {}
	for _, ent in pairs(minetest.luaentities) do
		if ent.settle_check and ent.maxy then
			local p = ent.object:get_pos()
			if p then
				local hash = hash_node_position(round(pos))
				local set = bypos[hash]
				if not set then
					set = {}
					bypos[hash] = set
				end
				set[ent] = true
			end
		end
	end
	local queue = {idx = {}, ents = {}}
	yqinsertall(queue, bypos, pos)
	pos.y = pos.y + 1
	yqinsertall(queue, bypos, pos)
	while #queue.idx > 0 do
		local key = queue.idx[1]
		local ents = queue.ents[key]
		local ent = ents[#ents]
		if #ents == 1 then
			queue.ents[key] = nil
			table_remove(queue.idx, 1)
		else
			ents[#ents] = nil
		end
		local p = round(ent.object:get_pos())
		local maxy = math_floor(ent.maxy + 0.5)
		while true do
			local c = blocked[hash_node_position(p)]
			if p.y >= maxy or not (c and c ~= area_unloaded) then
				ent.object:set_pos(p)
				break
			end
			p.y = p.y + 1
		end
		ent:settle_check()
		if collides(p) then
			blocked[hash_node_position(p)] = true
			yqinsertall(queue, bypos, p)
			p.y = p.y + 1
			yqinsertall(queue, bypos, p)
		end
	end
	entity_settle_recursing = nil
end

function nodecore.entity_settle_check(on_settle, isnode)
	return function(self)
		local pos = self.object:get_pos()
		if not pos then return end
		if pos.y < nodecore.map_limit_min then
			pos.y = nodecore.map_limit_min
			self.object:set_pos(pos)
			local vel = self.object:get_velocity()
			vel.y = 0
			self.object:set_velocity(vel)
		end

		if self.settle_oldpos and vector.distance(self.settle_oldpos, pos) < 1/16 then
			local csize = self.collidesize or 0.5
			pos.x = pos.x + (math_random() * 2 - 1) * csize
			pos.z = pos.z + (math_random() * 2 - 1) * csize
		else
			self.settle_oldpos = pos
		end

		local yvel = self.object:get_velocity().y
		local coll = (isnode or self.not_rising and yvel == 0)
		and collides({x = pos.x, y = pos.y - 0.75, z = pos.z})
		self.not_rising = yvel <= 0
		if not coll then
			if self.setvel then
				if self.vel then self.object:set_velocity(self.vel) end
				self.setvel = nil
			end
			self.vel = self.object:get_velocity()
			return nodecore.grav_air_accel_ent(self.object)
		end
		if coll == area_unloaded then
			self.object:set_velocity({x = 0, y = 0, z = 0})
			self.object:set_acceleration({x = 0, y = 0, z = 0})
			self.setvel = true
			return
		end
		pos = vector.round(pos)

		if not on_settle(self, pos, collides) then return end
		nodecore.entity_settle_recurse(pos)

		return nodecore.fallcheck(pos)
	end
end

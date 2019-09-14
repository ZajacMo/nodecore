-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, setmetatable, unpack
    = ItemStack, math, minetest, nodecore, pairs, setmetatable, unpack
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function readd(oldadd, pos, item, ...)
	local stack = ItemStack(item)
	item = stack:get_name()
	if stack:get_count() ~= 1 or (not
		minetest.registered_nodes[item]) then
		return oldadd(pos, item, ...)
	end
	local npos = nodecore.scan_flood(pos, 5,
		function(p)
			if p.y > pos.y and math_random() < 0.95 then return end
			if p.y > pos.y + 1 then return end
			if nodecore.buildable_to(p) then return p end
		end)
	if not npos then return oldadd(pos, item, ...) end
	minetest.set_node(npos, {name = item})
end

local bifn = minetest.registered_entities["__builtin:falling_node"]
local falling = {
	set_node = function(self, node, meta, ...)
		if node and node.name == modname .. ":stack"
		and meta and meta.inventory and meta.inventory.solo then
			local stack = ItemStack(meta.inventory.solo[1] or "")
			if not stack:is_empty() then
				local ent = minetest.add_item(self.object:get_pos(), stack)
				if ent then ent:set_velocity({x = 0, y = 0, z = 0}) end
				return self.object:remove()
			end
		end
		return bifn.set_node(self, node, meta, ...)
	end,
	on_step = function(...)
		local oldadd = minetest.add_item
		local drops = {}
		minetest.add_item = function(pos, item, ...)
			drops[#drops + 1] = {pos, item, ...}
		end
		local oldnode = minetest.add_node
		minetest.add_node = function(pos, node, ...)
			oldnode(pos, node, ...)
			for _, v in pairs(drops) do
				readd(oldadd, unpack(v))
			end
			drops = {}
		end
		local function helper(...)
			minetest.add_item = oldadd
			minetest.add_node = oldnode
			return ...
		end
		return helper(bifn.on_step(...))
	end
}
setmetatable(falling, bifn)
minetest.register_entity(":__builtin:falling_node", falling)

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

		local pos = obj:get_pos()
		return pos and vector.equals(vector.round(pos), rp)
	end
end

local hash = minetest.hash_node_position
local unhash = minetest.get_position_from_hash

local check_queue = {}
local check_queue_dirty
local function visinv_update_ents(pos)
	pos = vector.round(pos)
	check_queue[hash(pos)] = pos
	check_queue_dirty = true
end
nodecore.visinv_update_ents = visinv_update_ents

local function itemcheck(self)
	local obj = self.object
	if not (obj and obj:get_pos()) then return end

	local rp = self.pos
	local nodemeta = minetest.get_meta(rp)
	local tweenfrom = minetest.deserialize(nodemeta:get_string("tweenfrom"))

	local stack = nodecore.stack_get(rp)

	local sstr = stack:to_string()
	if (not tweenfrom) and self.stackstring == sstr then return end
	self.stackstring = sstr

	if stack:is_empty() then return self.object:remove() end

	local def = minetest.registered_items[stack:get_name()] or {}
	local src = def.light_source or 0
	if src > 0 then
		self.light_source = src
		nodecore.dynamic_light_add(rp, src, getlightcheck(rp, obj, src))
	end

	local props, scale, yaw = nodecore.stackentprops(stack,
		rp.x * 3 + rp.y * 5 + rp.z * 7)
	local op = {
		x = rp.x,
		y = rp.y + scale - 31/64,
		z = rp.z
	}
	self.homepos = op

	if tweenfrom then
		nodemeta:set_string("tweenfrom", "")
		obj:set_pos(tweenfrom)
		obj:move_to(op)
	elseif not vector.equals(obj:get_pos(), op) then
		obj:set_pos(op)
	end

	if obj:get_yaw() ~= yaw then
		obj:set_yaw(yaw)
	end

	return obj:set_properties(props)
end

local entname = modname .. ":stackent"
minetest.register_entity(entname, {
		initial_properties = nodecore.stackentprops(),
		is_stack = true,
		itemcheck = itemcheck
	})

local check_retry
local function check_retry_add(key, val)
	if not check_retry then
		check_retry = {}
		minetest.after(1 + math_random(), function()
				local total = 0
				for k, v in pairs(check_retry) do
					total = total + 1
					check_queue[k] = v
				end
				check_queue_dirty = true
				check_retry = nil
				nodecore.log("warning", "visinv entity retry: " .. total)
			end)
	end
	check_retry[key] = val
end

local visinv_hidden = nodecore.group_expand("group:visinv_hidden", true)

nodecore.register_globalstep(function()
		if not check_queue_dirty then return end
		local batch = check_queue
		check_queue = {}
		check_queue_dirty = nil

		local allents = {}
		for _, ent in pairs(minetest.luaentities) do
			if ent.name == entname then
				allents[#allents + 1] = ent
			end
		end
		for i = 1, #allents do
			local ent = allents[i]
			local key = ent.poskey
			if key then
				local data = batch[key]
				if data then
					-- XXX: The meaning of data.n has been lost in time, and it
					-- may be part of a past optimization that was removed, and
					-- possibly should be removed itself.
					if data.n then
						ent.object:remove()
					else
						if not visinv_hidden[minetest.get_node(data).name] then
							itemcheck(ent)
							data.n = true
						else
							ent.object:remove()
						end
					end
				end
			end
		end

		for poskey, data in pairs(batch) do
			if (not data.n) and (not nodecore.stack_get(data):is_empty())
			and (not visinv_hidden[minetest.get_node(data).name]) then
				local obj = minetest.add_entity(data, entname)
				local ent = obj and obj:get_luaentity()
				if ent then
					ent.is_stack = true
					ent.poskey = poskey
					ent.pos = unhash(poskey)
					itemcheck(ent)
				else
					check_retry_add(poskey, data)
				end
			end
		end
	end)

------------------------------------------------------------------------
-- NODE REGISTRATION HELPERS

function nodecore.visinv_on_construct(pos)
	return nodecore.visinv_update_ents(pos)
end

function nodecore.visinv_after_destruct(pos)
	nodecore.visinv_update_ents(pos)
	return nodecore.fallcheck(pos)
end

nodecore.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end

		def.groups = def.groups or {}

		if def.groups.visinv then
			def.can_have_itemstack = true
			def.on_construct = def.on_construct or nodecore.visinv_on_construct
			def.after_destruct = def.after_destruct or nodecore.visinv_after_destruct
		end
	end)

nodecore.register_lbm({
		name = modname .. ":init",
		run_at_every_load = true,
		nodenames = {"group:visinv"},
		action = function(...) return nodecore.visinv_update_ents(...) end
	})

nodecore.register_abm({
		label = "visinv check",
		interval = 2,
		chance = 1,
		nodenames = {"group:visinv"},
		action = function(...) return nodecore.visinv_update_ents(...) end
	})

------------------------------------------------------------------------
-- DIG INVENTORY

nodecore.register_on_node_drops(function(pos, _, who, drops)
		nodecore.stack_sounds(pos, "dug")
		local stack = nodecore.stack_get(pos)
		if stack and not stack:is_empty() then
			local def = stack:get_definition()
			local grps = def and def.groups
			local dmg = grps.damage_pickup
			if (dmg or 0) == 0 then dmg = def.groups.damage_touch end
			if who and dmg and dmg > 0 then
				local wield = who:get_wielded_item()
				local wdef = wield and minetest.registered_items[wield:get_name()]
				local ovr = wdef and wdef.on_item_hotpotato
				local widx = ovr and who:get_wield_index()
				if ovr and ovr(who, widx, wield, widx, stack, dmg) then dmg = 0 end
			end
			if who and dmg and dmg > 0 then
				nodecore.addphealth(who, -dmg, "hot pickup")
				nodecore.item_eject(pos, stack, 0.001)
			else
				drops[#drops + 1] = stack
			end
		end
	end)

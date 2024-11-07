-- LUALOCALS < ---------------------------------------------------------
local core, math, nc, pairs, vector
    = core, math, nc, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

nc.amcoremod()

--[[
Helpers for visible inventory. Use "visinv" node group.
Sets up on_construct, after_destruct and an ABM to manage
the visual entities.
--]]

local modname = core.get_current_modname()

------------------------------------------------------------------------
-- VISIBLE STACK ENTITY

local function getlightcheck(rp, obj, src)
	return function()
		local stack = nc.stack_get(rp)
		if not stack or stack:is_empty() then return end

		local def = core.registered_items[stack:get_name()] or {}
		if (def.light_source or 0) ~= src then return end

		local pos = obj:get_pos()
		return pos and vector.equals(vector.round(pos), rp)
	end
end

local hash = core.hash_node_position
local unhash = core.get_position_from_hash

local check_queue = {}
local check_queue_dirty
local function visinv_update_ents(pos)
	pos = vector.round(pos)
	check_queue[hash(pos)] = pos
	check_queue_dirty = true
end
nc.visinv_update_ents = visinv_update_ents

local tweenfrom = {}
function nc.visinv_tween_from(nodepos, frompos)
	tweenfrom[hash(vector.round(nodepos))] = frompos
end

local function itemcheck(self)
	local obj = self.object
	if not (obj and obj:get_pos()) then return end

	local rp = self.pos
	local tf = tweenfrom[self.poskey]
	local stack = nc.stack_get(rp)
	local sstr = stack:to_string()
	if (not tf) and self.stackstring == sstr then return end
	self.stackstring = sstr

	if stack:is_empty() then return self.object:remove() end

	local def = core.registered_items[stack:get_name()] or {}
	local src = def.light_source or 0
	if src > 0 then
		self.light_source = src
		nc.dynamic_light_add(rp, src, getlightcheck(rp, obj, src))
	end

	local props, scale, yaw = nc.stackentprops(stack,
		rp.x * 3 + rp.y * 5 + rp.z * 7)
	local op = {
		x = rp.x,
		y = rp.y + scale - 31/64,
		z = rp.z
	}
	self.homepos = op

	if tf then
		tweenfrom[self.poskey] = nil
		obj:set_pos(tf)
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
core.register_entity(entname, {
		initial_properties = nc.stackentprops(),
		is_stack = true,
		itemcheck = itemcheck
	})

local check_retry
local function check_retry_add(key, val)
	if not check_retry then
		check_retry = {}
		core.after(1 + math_random(), function()
				local total = 0
				for k, v in pairs(check_retry) do
					total = total + 1
					check_queue[k] = v
				end
				check_queue_dirty = true
				check_retry = nil
				nc.log("warning", "visinv entity retry: " .. total)
			end)
	end
	check_retry[key] = val
end

local visinv_hidden = nc.group_expand("group:visinv_hidden", true)

nc.register_globalstep(function()
		if not check_queue_dirty then return end
		local batch = check_queue
		check_queue = {}
		check_queue_dirty = nil

		for _, ent in pairs(core.luaentities) do
			if ent.name == entname then
				local key = ent.poskey
				if key then
					local data = batch[key]
					if data then
						if data.entexists then
							ent.object:remove() -- duplicate
						elseif not visinv_hidden[core.get_node(data).name] then
							itemcheck(ent)
							data.entexists = true
						else
							ent.object:remove()
						end
					end
				end
			end
		end

		for poskey, data in pairs(batch) do
			if (not data.entexists) and (not nc.stack_get(data):is_empty())
			and (not visinv_hidden[core.get_node(data).name]) then
				local obj = core.add_entity(data, entname)
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

function nc.visinv_on_construct(pos)
	return nc.visinv_update_ents(pos)
end

function nc.visinv_after_destruct(pos)
	nc.visinv_update_ents(pos)
	return nc.fallcheck(pos)
end

nc.register_on_register_item(function(_, def)
		if def.type ~= "node" then return end

		def.groups = def.groups or {}

		if def.groups.visinv then
			def.can_have_itemstack = true
			def.on_construct = def.on_construct or nc.visinv_on_construct
			def.after_destruct = def.after_destruct or nc.visinv_after_destruct
		end
	end)

nc.register_lbm({
		name = modname .. ":init",
		run_at_every_load = true,
		nodenames = {"group:visinv"},
		action = function(...) return nc.visinv_update_ents(...) end
	})

nc.register_abm({
		label = "visinv check",
		interval = 2,
		chance = 1,
		nodenames = {"group:visinv"},
		action = function(...) return nc.visinv_update_ents(...) end
	})

------------------------------------------------------------------------
-- DIG INVENTORY

nc.register_on_node_drops(function(pos, _, who, drops)
		nc.stack_sounds(pos, "dug")
		local stack = nc.stack_get(pos)
		if stack and not stack:is_empty() then
			local def = stack:get_definition()
			local grps = def and def.groups
			local dmg = grps.damage_pickup
			if (dmg or 0) == 0 then dmg = def.groups.damage_touch end
			if who and dmg and dmg > 0 then
				local wield = who:get_wielded_item()
				local wdef = wield and core.registered_items[wield:get_name()]
				local ovr = wdef and wdef.on_item_hotpotato
				local widx = ovr and who:get_wield_index()
				if ovr and ovr(who, widx, wield, widx, stack, dmg) then dmg = 0 end
			end
			if who and dmg and dmg > 0 then
				nc.addphealth(who, -dmg, "hot pickup")
				nc.item_eject(pos, stack, 0.001)
			else
				drops[#drops + 1] = stack
			end
		end
	end)

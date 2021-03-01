-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, string, table, vector
    = minetest, nodecore, pairs, string, table, vector
local string_format, table_remove
    = string.format, table.remove
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

for _, n in pairs({"slot", "sel"}) do
	minetest.register_craftitem(modname .. ":" .. n, {
			description = "",
			inventory_image = "nc_player_wield_" .. n .. ".png",
			virtual_item = true
		})
end

local xyz = function(n) return {x = n, y = n, z = n} end
local bbox = function(n) return {-n, -n, -n, n, n, n} end
local size_w_item = xyz(0.2)
local size_w_tool = xyz(0.3)
local size_slot = xyz(0.15)
local size_item = xyz(0.1)

local hidden = {is_visible = false}
local selslot = {
	is_visible = true,
	selectionbox = bbox(0),
	visual = "upright_sprite",
	visual_size = size_slot,
	textures = {modname .. "_sel.png"}
}
local emptyslot = {
	is_visible = true,
	selectionbox = bbox(0),
	visual = "upright_sprite",
	visual_size = size_slot,
	textures = {modname .. "_slot.png"}
}

local function calcprops(itemname, iswield)
	local def = minetest.registered_items[itemname]
	if def and def.virtual_item then return hidden end
	if itemname == "" then return iswield and hidden or emptyslot end
	local size = iswield and (def and def.type == "tool" and size_w_tool
		or size_w_item) or (itemname == "" and size_slot) or size_item
	return {
		is_visible = true,
		visual_size = size,
		selectionbox = bbox(size.x),
		visual = "wielditem",
		textures = {itemname},
		glow = def and (def.light_source or def.glow or 0)
	}
end

local propcache_item = {}
local propcache_wield = {}
local function itemprops(itemname, iswield)
	local cache = iswield and propcache_wield or propcache_item
	local found = cache[itemname]
	if found then return found end
	found = calcprops(itemname, iswield)
	cache[itemname] = found
	return found
end

local playerdata = {}
nodecore.register_globalstep("player wield show check", function()
		playerdata = {}
		for _, player in pairs(minetest.get_connected_players()) do
			local pname = player:get_player_name()
			if nodecore.interact(pname) and nodecore.player_visible(pname) then
				playerdata[pname] = {
					player = player,
					inv = player:get_inventory():get_list("main"),
					widx = player:get_wield_index()
				}
			else
				playerdata[pname] = false
			end
		end
	end)

local entdef
entdef = {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = bbox(0),
		selectionbox = bbox(0),
		textures = {""},
		is_visible = false,
		static_save = false,
		glow = 0
	},
	on_activate = function(self)
		self.on_step = entdef.on_step
	end,
	on_step = function(self)
		local conf = self.conf
		if not conf then return self.object:remove() end

		local pdata = playerdata[conf.pname]
		if pdata == nil then return self.object:remove() end
		if not pdata then return self.object:set_properties(hidden) end

		if not self.att then
			self.att = true
			return self.object:set_attach(pdata.player,
				conf.bone, conf.apos, conf.arot)
		end

		local widx = pdata.widx
		if conf.slot == widx then
			return self.object:set_properties(selslot)
		end

		return self.object:set_properties(itemprops(
				pdata.inv[conf.slot or widx]:get_name(),
				not conf.slot))
	end,
	on_punch = function(self, puncher)
		local objpos = self.object:get_pos()
		if not objpos then return end

		if not (puncher and puncher:is_player()) then return end

		local conf = self.conf
		if not conf then return end
		local pdata = playerdata[conf.pname]
		if not pdata then return end

		local ppos = pdata.player:get_pos()
		local diff = vector.subtract(ppos, puncher:get_pos())
		if vector.dot(diff, diff) > 4 then return end

		local face = minetest.yaw_to_dir(pdata.player:get_look_horizontal())
		if vector.dot(face, diff) >= 0 then return end

		local inv = pdata.player:get_inventory()
		local slot = conf.slot or pdata.widx
		local stack = inv:get_stack("main", slot)

		local stime = self.swipetime or 0
		if stime < nodecore.gametime - 0.5 then
			self.swipetime = nodecore.gametime
			nodecore.stack_sounds(objpos, "dig", stack)
			nodecore.sound_play(modname .. "_swipe",
				{object = self.object, gain = 0.25})
			local stackdef = stack:get_definition()
			if stackdef then
				local spos = {
					x = ppos.x,
					y = ppos.y + 1,
					z = ppos.z
				}
				local vel = vector.multiply(vector.normalize(diff), -2)
				nodecore.digparticles(stackdef, {
						time = 0.5,
						amount = 20,
						minpos = spos,
						maxpos = spos,
						minvel = vector.multiply(vel, 0.75),
						maxvel = vel,
						minacc = {x = 0, y = 0, z = 0},
						maxacc = {x = 0, y = 0, z = 0},
						minexptime = 0.25,
						maxexptime = 1,
						minsize = 1,
						maxsize = 2
					})
			end
		end

		local pname = puncher:get_player_name()
		local tname = self.thief_name
		if not tname or tname ~= pname then
			self.thief_name = pname
			self.thief_start = nodecore.gametime
			self.thief_last = nodecore.gametime
			return
		end

		if nodecore.gametime > self.thief_last + 2 then
			self.thief_name = nil
			return
		end
		if nodecore.gametime < self.thief_start + 4.25 then
			self.thief_last = nodecore.gametime
			return
		end

		self.thief_name = nil
		local oname = nodecore.stack_shortdesc(stack, true)
		local orig = stack:get_count()
		stack = puncher:get_inventory():add_item("main", stack)
		local left = stack:get_count()
		inv:set_stack("main", slot, stack)

		return nodecore.log("action", string_format(
				"%s pickpockets stack %q %d - %d = %d from %s slot %d",
				pname, oname, orig, orig - left, left, conf.pname, slot,
				minetest.pos_to_string(ppos)))
	end
}
minetest.register_entity(modname .. ":ent", entdef)

local attq = {}
local running
local function pumpqueue()
	local v = table_remove(attq, 1)
	if not v then running = nil return end
	minetest.after(0, pumpqueue)

	local player = minetest.get_player_by_name(v.pname)
	if not player then return end

	if not minetest.get_node_or_nil(player:get_pos()) then
		attq[#attq + 1] = v
		return
	end

	local obj = minetest.add_entity(v.pos, modname .. ":ent")
	local ent = obj:get_luaentity()
	ent.conf = v
end

nodecore.register_on_joinplayer("join setup wieldview", function(player)
		local pname = player:get_player_name()
		local pos = player:get_pos()

		local function addslot(n, b, x, y, z, rx, ry, rz)
			attq[#attq + 1] = {
				pname = pname,
				slot = n,
				pos = pos,
				bone = b,
				apos = {
					x = x,
					y = y,
					z = z
				},
				arot = {
					x = rx or 0,
					y = ry or 180,
					z = rz or 0
				}
			}
		end

		addslot(nil, "Arm_Right", 0, 7, 2, -90, 200, 90)

		local function cslot(n, x, y, z)
			return addslot(n, "Bandolier", x * 0.8,
				0.75 + y * 1.6,
				-0.25 + z)
		end

		cslot(1, 1.75, 0, 0)
		cslot(2, -1, 1, 0.05)
		cslot(3, 1, 2, 0.1)
		cslot(4, -1.75, 3, 0.02)
		cslot(5, 1.75, 3, 0.02)
		cslot(6, -1, 2, 0.1)
		cslot(7, 1, 1, 0.05)
		cslot(8, -1.75, 0, 0)

		if not running then
			running = true
			minetest.after(0, pumpqueue)
		end
	end)

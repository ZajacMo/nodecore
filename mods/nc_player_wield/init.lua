-- LUALOCALS < ---------------------------------------------------------
local math, minetest, nodecore, pairs, table
    = math, minetest, nodecore, pairs, table
local math_random, table_remove
    = math.random, table.remove
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local function newttl()
	return 30 + math_random() * 30
end

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

local hidden = {
	is_visible = false,
	glow = 0
}
local selslot = {
	is_visible = true,
	visual = "upright_sprite",
	visual_size = size_slot,
	textures = {modname .. "_sel.png"},
	glow = 0
}
local emptyslot = {
	is_visible = true,
	visual = "upright_sprite",
	visual_size = size_slot,
	textures = {modname .. "_slot.png"},
	glow = 0
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

local attq = {}
local running
local function pumpqueue()
	local v = table_remove(attq, 1)
	if not v then running = nil return end
	minetest.after(0, pumpqueue)

	local player = minetest.get_player_by_name(v.pname)
	if not player then return end

	local pos = player:get_pos()
	if not minetest.get_node_or_nil(pos) then
		attq[#attq + 1] = v
		return
	end

	local obj = minetest.add_entity(pos, modname .. ":ent")
	local ent = obj:get_luaentity()
	ent.conf = v
end
local function startqueue()
	if running then return end
	running = true
	minetest.after(0, pumpqueue)
end

local entdef
entdef = {
	initial_properties = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = bbox(0),
		selectionbox = bbox(0),
		textures = {""},
		pointable = false,
		is_visible = false,
		static_save = false,
		glow = 0
	},
	on_activate = function(self)
		self.on_step = entdef.on_step
	end,
	on_step = function(self, dtime)
		local conf = self.conf
		if not conf then return self.object:remove() end

		local pdata = playerdata[conf.pname]
		if pdata == nil then return self.object:remove() end
		if not pdata then return self.object:set_properties(hidden) end

		if not self.att then
			self.att = true
			self.object:set_attach(pdata.player,
				conf.bone, conf.apos, conf.arot)
		end

		if conf.oldent then
			conf.oldent:remove()
			conf.oldent = nil
		end

		local ttl = self.ttl or newttl()
		if ttl > 0 then
			ttl = ttl - dtime
			if ttl <= 0 then
				local t = {}
				for k, v in pairs(conf) do t[k] = v end
				t.oldent = self.object
				attq[#attq + 1] = t
				startqueue()
			end
		end
		self.ttl = ttl

		local widx = pdata.widx
		if conf.slot == widx then
			return self.object:set_properties(selslot)
		end

		return self.object:set_properties(itemprops(
				pdata.inv[conf.slot or widx]:get_name(),
				not conf.slot))
	end
}
minetest.register_entity(modname .. ":ent", entdef)

nodecore.register_on_joinplayer("join setup wieldview", function(player)
		local pname = player:get_player_name()

		local function addslot(n, b, x, y, z, rx, ry, rz)
			attq[#attq + 1] = {
				pname = pname,
				slot = n,
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
				2 + y * 1.6,
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

		startqueue()
	end)

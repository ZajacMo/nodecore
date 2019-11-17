-- LUALOCALS < ---------------------------------------------------------
local ItemStack, minetest, nodecore, table
    = ItemStack, minetest, nodecore, table
local table_remove
    = table.remove
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

local function entprops(stack, conf)
	local t = {
		hp_max = 1,
		physical = false,
		collide_with_objects = false,
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = "wielditem",
		visual_size = {x = 0.1, y = 0.1, z = 0.1},
		textures = {""},
		spritediv = {x = 1, y = 1},
		initial_sprite_basepos = {x = 0, y = 0},
		is_visible = false,
		static_save = false
	}
	if not stack then return t end
	if stack:is_empty() then return t end
	local def = minetest.registered_items[stack:get_name()] or {}
	if def.virtual_item then return t end
	t.is_visible = true
	t.textures[1] = stack:get_name()
	if conf and not conf.slot then
		t.visual_size = {x = 0.2, y = 0.2, z = 0.2}
	end
	return t
end

local attq = {}

minetest.register_entity(modname .. ":ent", {
		initial_properties = entprops(),
		on_step = function(self)
			local conf = self.conf
			if not conf then return self.object:remove() end

			local player = minetest.get_player_by_name(conf.pname)
			if not player then return self.object:remove() end

			if not self.att then
				self.att = true
				return self.object:set_attach(player,
					conf.bone, conf.apos, conf.arot)
			end

			local inv = player:get_inventory()
			local w = player:get_wield_index()
			local s = conf.slot
			if s == w then s = nil else s = s or w end

			local stack = s and inv:get_stack("main", s) or ItemStack("")
			local sn = stack:get_name()
			if sn ~= self.sn then
				self.sn = sn
				self.object:set_properties(entprops(stack, conf))
			end
		end
	})

minetest.register_globalstep(function()
		local v = table_remove(attq, 1)
		if not v then return end

		local player = minetest.get_player_by_name(v.pname)
		if not player then return end

		if not minetest.get_node_or_nil(player:get_pos()) then
			attq[#attq + 1] = v
			return
		end

		local obj = minetest.add_entity(v.pos, modname .. ":ent")
		local ent = obj:get_luaentity()
		ent.conf = v
	end)

minetest.register_on_joinplayer(function(player)
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
					y = ry or 0,
					z = rz or 0
				}
			}
		end

		addslot(nil, "Arm_Right", -2.5, 8, 0, 2, 178, 60)

		local function cslot(n, x, y, z)
			return addslot(n, nil, x * 0.8,
				8.5 + y * 1.6,
				2.25 + z)
		end

		cslot(1, -1.75, 0, 0)
		cslot(2, 1, 1, 0.05)
		cslot(3, -1, 2, 0.1)
		cslot(4, 1.75, 3, 0.02)
		cslot(5, -1.75, 3, 0.02)
		cslot(6, 1, 2, 0.1)
		cslot(7, -1, 1, 0.05)
		cslot(8, 1.75, 0, 0)
	end)

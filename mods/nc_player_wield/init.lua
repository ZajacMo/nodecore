-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, table
    = minetest, nodecore, table
local table_remove
    = table.remove
-- LUALOCALS > ---------------------------------------------------------

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
	if conf and conf.slot == 0 then
		t.visual_size = {x = 0.2, y = 0.2, z = 0.2}
	end
	return t
end

local attq = {}

minetest.register_entity(modname .. ":ent", {
		initial_properties = entprops(),
		on_step = function(self, dtime)
			local conf = self.conf
			if not conf then return self.object:remove() end

--			if self.ttl then
--				self.ttl = self.ttl - dtime
--				if self.ttl <= 0 then
--					attq[#attq + 1] = conf
--					return self.object:remove()
--				end
--			else self.ttl = math_random() * 5 + 5 end

			local player = minetest.get_player_by_name(conf.pname)
			if not player then return self.object:remove() end

			if not self.att then
				self.att = true
				return self.object:set_attach(player,
					conf.bone, conf.apos, conf.arot)
			end

			local inv = player:get_inventory()
			local sz = inv:get_size("main")
			local s = conf.slot + player:get_wield_index()
			if s > sz then s = s - sz end

			local stack = inv:get_stack("main", s)
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

		addslot(0, "Arm_Right", -2.5, 8, 0, 2, 178, 60)

		local function cslot(n, x, z)
			return addslot(n, nil, x * 1.6,
				(nodecore.mt_old and -4 or 5.5) + x / 2,
				z * 2.1)
		end

		cslot(1, 1, 1)
		cslot(2, 0, 1.2)
		cslot(3, -1, 1)
		cslot(4, -2, 0)
		cslot(5, -1, -1)
		cslot(6, 0, -1.2)
		cslot(7, 1, -1)
	end)

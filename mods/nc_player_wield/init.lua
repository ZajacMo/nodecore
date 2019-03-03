-- LUALOCALS < ---------------------------------------------------------
local minetest
    = minetest
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local function entprops(stack)
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
		is_visible = false
	}
	if stack and (not stack:is_empty()) then
		t.is_visible = true
		t.textures[1] = stack:get_name()
	end
	return t
end

minetest.register_entity(modname .. ":ent", {
		initial_properties = entprops(),
		on_step = function(self, dtime)
			if self.pname and self.slot then
				local player = minetest.get_player_by_name(self.pname)
				if not player then return self.object:destroy() end

				local inv = player:get_inventory()
				local sz = inv:get_size("main")
				local s = self.slot + player:get_wield_index()
				if s > sz then s = s - sz end

				local stack = inv:get_stack("main", s)
				local sn = stack:get_name()
				if sn ~= self.sn then
					self.sn = sn
					local props = entprops(stack)
					if self.slot == 0 then
						props.visual_size = {x = 0.2, y = 0.2, z = 0.2}
					end
					self.object:set_properties(props)
				end
			end
		end
	})


minetest.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		local pos = player:get_pos()

		local function addslot(n, b, x, y, z, rx, ry, rz)
			local obj = minetest.add_entity(pos, modname .. ":ent")
			obj:set_attach(player, b,
				{x = x, y = y, z = z},
				{x = rx or 0, y = ry or 0, z = rz or 0})
			local ent = obj:get_luaentity()
			ent.pname = pname
			ent.slot = n
		end

		addslot(0, "Arm_Right", -2, 7, 0, 0, 180, 90)

		local function cslot(n, x, z)
			return addslot(n, nil, x * 1.5, -4 + x / 2, z * 2)
			--return addslot(n, "Chest", x * 1.5, -2.5 + x / 2, z * 2)
		end

		cslot(1, 1, 1)
		cslot(2, 0, 1)
		cslot(3, -1, 1)
		cslot(4, -2, 0)
		cslot(5, -1, -1)
		cslot(6, 0, -1)
		cslot(7, 1, -1)
	end)

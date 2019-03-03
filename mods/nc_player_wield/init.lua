-- LUALOCALS < ---------------------------------------------------------
local ipairs, minetest, string
    = ipairs, minetest, string
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

local attq = {}
local qpos = 0

minetest.register_globalstep(function()
		if not attq then return end
		qpos = qpos + 1
		if qpos > #attq then
			attq = nil
			qpos = nil
			return
		end
		local v = attq[qpos]
		local player = minetest.get_player_by_name(v.pname)
		if not player then return end
		local obj = minetest.add_entity(v.pos, modname .. ":ent")
		obj:set_attach(player, v.bone,
			{x = v.x, y = v.y, z = v.z},
			{x = v.rx, y = v.ry, z = v.rz})
		local ent = obj:get_luaentity()
		ent.pname = v.pname
		ent.slot = v.slot
	end)


minetest.register_on_joinplayer(function(player)
		local pname = player:get_player_name()
		local pos = player:get_pos()

		local myq = {}

		minetest.after(1, function()
				if not attq then
					attq = {}
					qpos = 0
				end
				for _, v in ipairs(myq) do attq[#attq + 1] = v end
			end)

		local function addslot(n, b, x, y, z, rx, ry, rz)
			myq[#myq + 1] = {
				slot = n,
				pname = pname,
				pos = pos,
				bone = b,
				x = x,
				y = y,
				z = z,
				rx = rx or 0,
				ry = ry or 0,
				rz = rz or 0}
		end

		addslot(0, "Arm_Right", -2, 7, 0, 0, 180, 90)

		local isold = minetest.get_version().string:sub(1, 2) == "0."
		local function cslot(n, x, z)
			return addslot(n, nil, x * 1.5,
				(isold and -4 or 5.5) + x / 2,
				z * 2)
		end

		cslot(1, 1, 1)
		cslot(2, 0, 1)
		cslot(3, -1, 1)
		cslot(4, -2, 0)
		cslot(5, -1, -1)
		cslot(6, 0, -1)
		cslot(7, 1, -1)
	end)

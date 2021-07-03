-- LUALOCALS < ---------------------------------------------------------
local minetest, nodecore, pairs, vector
    = minetest, nodecore, pairs, vector
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local anims = {}
do
	local raw = {0, 53, 165}
	raw[#raw + 1] = raw[1]
	for i = 1, #raw - 1 do
		anims[raw[i]] = raw[i + 1]
	end
end

minetest.register_entity(modname .. ":ent", {
		initial_properties = {
			visual = "mesh",
			visual_size = {x = 0.9, y = 0.9, z = 0.9},
			mesh = "nc_player_model.b3d",
			textures = {"nc_player_model_base.png"},
			collisionbox = {-0.25, 0, -0.25, 0.25, 2, 0.25},
			physical = true
		},
		get_staticdata = function(self)
			return minetest.serialize(self.data)
		end,
		on_activate = function(self, data)
			self.data = data and minetest.deserialize(data) or {}
			local obj = self.object
			local pos = obj:get_pos()
			local skinopts = {
				playername = minetest.pos_to_string(pos) .. 2,
				nometa = true,
				privs = {interact = true, shout = true}
			}
			obj:set_properties({textures = {nodecore.player_skin(nil, skinopts)}})
			obj:set_acceleration({x = 0, y = -10, z = 0})
			local anim = self.data.anim or 0
			obj:set_animation({x = anim, y = anim}, 1)
			nodecore.mock_player_wieldview(self)
		end,
		on_punch = function(self, whom)
			if not whom then return end
			local obj = self.object
			local ctl = whom:get_player_control()
			if ctl.RMB and ctl.sneak then
				return obj:remove()
			end
			if ctl.RMB then
				local pos = obj:get_pos()
				if not pos then return end
				pos = vector.add(pos, vector.multiply(vector.direction(
							whom:get_pos(), pos), 0.25))
				pos.y = pos.y + 1
				return obj:set_pos(pos)
			end
			if ctl.sneak then
				self.data.wield = {
					inv = whom:get_inventory():get_list("main"),
					widx = whom:get_wield_index()
				}
				for k, v in pairs(self.data.wield.inv) do
					self.data.wield.inv[k] = v:get_name()
				end
				nodecore.mock_player_wieldview(self)
				return
			end
			local pos = obj:get_pos()
			if not pos then return end
			local dir = vector.direction(pos, whom:get_pos())
			obj:set_yaw(minetest.dir_to_yaw(dir))
			local anim = anims[self.data.anim or 0]
			self.data.anim = anim
			obj:set_animation({x = anim, y = anim}, 1)
		end
	})

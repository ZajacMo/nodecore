-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, vector
    = ipairs, math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

local sparks = {}
local sparkqty = 0
local sparkmax = 50
nodecore.register_globalstep("fire sparks", function()
		if sparkqty < 1 then return end
		for i = 1, #sparks do
			local pos = sparks[i]
			minetest.after(math_random(), function()
					minetest.add_particlespawner({
							amount = math_random(1, 3),
							time = 1,
							minpos = vector.subtract(pos, 0.5),
							maxpos = vector.add(pos, 0.5),
							minvel = {x = -1, y = 2, z = -1},
							maxvel = {x = 1, y = 2.5, z = 1},
							minacc = {x = -0.1, y = 0, z = -0.1},
							maxacc = {x = 0.1, y = 0, z = 0.1},
							minxeptime = 1,
							maxexptime = 3,
							minsize = 0.1,
							maxsize = 0.2,
							collisiondetection = true,
							collision_removal = true,
							texture = "nc_fire_spark.png",
							glow = math_random(5, 9)
						})
				end)
		end
		sparks = {}
		sparkqty = 0
	end)

do
	local flamedirs = nodecore.dirs()
	local embers = {}
	minetest.after(0, function()
			for k, v in pairs(minetest.registered_items) do
				if v.groups.ember then
					embers[k] = true
				end
			end
		end)
	minetest.register_abm({
			label = "fire consume",
			interval = 1,
			chance = 1,
			nodenames = {modname .. ":fire"},
			action = function(pos)
				sparkqty = sparkqty + 1
				if sparkqty > sparkmax then
					local sparkid = math_random(1, sparkqty)
					if sparkid <= sparkmax then
						sparks[sparkid] = pos
					end
				else
					sparks[sparkqty] = pos
				end

				local found = {}
				for _, dp in ipairs(flamedirs) do
					local npos = vector.add(pos, dp)
					local node = minetest.get_node_or_nil(npos)
					if (not node) or embers[node.name] then
						found[#found + 1] = npos
					end
				end
				if #found < 1 then
					return minetest.remove_node(pos)
				end
				local picked = nodecore.pickrand(found)
				return nodecore.fire_check_expend(picked)
			end
		})
end

minetest.register_abm({
		label = "flammables ignite",
		interval = 5,
		chance = 1,
		nodenames = {"group:flammable"},
		neighbors = {"group:igniter"},
		neighbors_invert = true,
		action = function(pos)
			nodecore.fire_check_ignite(pos)
		end
	})

minetest.register_abm({
		label = "ember snuff/flames",
		interval = 1,
		chance = 1,
		nodenames = {"group:ember"},
		action = function(pos, node)
			local snuff, vents = nodecore.fire_check_snuff(pos, node)
			if snuff or not vents then return end
			for i = 1, #vents do
				if vents[i].q < 1 then
					minetest.set_node(vents[i], {name = modname .. ":fire"})
				end
			end
		end
	})

nodecore.register_ambiance({
		label = "flame ambiance",
		nodenames = {"group:flame_ambiance"},
		interval = 1,
		chance = 1,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.1
	})

nodecore.register_item_ambiance({
		label = "flame ambiance",
		itemnames = {"group:flame_ambiance"},
		interval = 1,
		chance = 1,
		sound_name = "nc_fire_flamy",
		sound_gain = 0.1
	})

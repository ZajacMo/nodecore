-- LUALOCALS < ---------------------------------------------------------
local ipairs, math, minetest, nodecore, pairs, string, vector
    = ipairs, math, minetest, nodecore, pairs, string, vector
local math_random, string_format
    = math.random, string.format
-- LUALOCALS > ---------------------------------------------------------

local modname = minetest.get_current_modname()

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
	nodecore.register_limited_abm({
			label = "fire consume",
			interval = 1,
			chance = 1,
			nodenames = {modname .. ":fire"},
			action = function(pos)
				if math_random(1, 5) == 1 then
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

local poshash = minetest.hash_node_position
local ignitemax = 250
local ignition
nodecore.register_globalstep("fire ignition", function()
		if not ignition then return end
		nodecore.log("info", string_format("fire ignition: %d (%d/%d)",
				ignition.qty, #ignition.queue, ignitemax))
		for _, pos in ipairs(ignition.queue) do
			nodecore.fire_check_ignite(pos)
		end
		ignition = nil
	end)
nodecore.register_limited_abm({
		label = "flammables ignite",
		interval = 5,
		chance = 1,
		nodenames = {"group:igniter"},
		neighbors = {"group:flammable"},
		action = function(pos)
			for _, p in pairs(nodecore.find_nodes_around(pos, "group:flammable")) do
				local key = poshash(p)
				if not ignition then
					ignition = {
						queue = {},
						seen = {},
						qty = 0
					}
				end
				local seen = ignition.seen
				if not seen[key] then
					seen[key] = true
					local qty = ignition.qty + 1
					ignition.qty = qty
					if qty > ignitemax then
						local i = math_random(1, qty)
						if i <= ignitemax then
							ignition.queue[i] = p
						end
					else
						ignition.queue[qty] = p
					end
				end
			end
		end
	})

nodecore.register_limited_abm({
		label = "ember consume",
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

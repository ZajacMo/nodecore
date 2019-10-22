-- LUALOCALS < ---------------------------------------------------------
local ItemStack, math, minetest, nodecore, pairs, vector
    = ItemStack, math, minetest, nodecore, pairs, vector
local math_random
    = math.random
-- LUALOCALS > ---------------------------------------------------------

nodecore.amcoremod()

local modname = minetest.get_current_modname()

minetest.register_node(modname .. ":root", {
		paramtype = "light",
		sunlight_propagates = true,
		drawtype = "airlike",
		light_source = 1,
		walkable = false,
		climbable = true,
		pointable = false,
		buildable_to = true,
		air_equivalent = true,
		groups = {[modname] = 1}
	})

minetest.register_node(modname .. ":branch", {
		paramtype = "light",
		sunlight_propagates = true,
		drawtype = "airlike",
		walkable = false,
		climbable = true,
		pointable = false,
		buildable_to = true,
		air_equivalent = true,
		groups = {[modname] = 1}
	})

minetest.register_node(modname .. ":floor", {
		paramtype = "light",
		sunlight_propagates = true,
		drawtype = "airlike",
		light_source = 1,
		walkable = false,
		pointable = false,
		buildable_to = true,
		air_equivalent = true,
		groups = {[modname] = 1}
	})

local function solid(pos)
	local node = minetest.get_node(pos)
	local def = minetest.registered_nodes[node.name]
	if def and def.walkable and (not nodecore.toolspeed(
			ItemStack(""), def.groups)) then return true end
end

local function findrel(pos, test)
	if test({x = pos.x, y = pos.y + 1, z = pos.z}) then
		return "ceil"
	end
	if test({x = pos.x + 1, y = pos.y, z = pos.z})
	or test({x = pos.x - 1, y = pos.y, z = pos.z})
	or test({x = pos.x, y = pos.y, z = pos.z + 1})
	or test({x = pos.x, y = pos.y, z = pos.z - 1}) then
		return "wall"
	end
end

local function closenough(pos, player)
	local pp = player:get_pos()
	pp.y = pp.y + 1
	return vector.distance(pos, pp) <= 5
end

local function anyclosenough(pos)
	for _, p in pairs(minetest.get_connected_players()) do
		if closenough(pos, p) then return true end
	end
end

local function sparkle(pos)
	minetest.add_particlespawner({
			texture = modname .. "_particle.png",
			collisiondetection = false,
			amount = 10,
			time = 5,
			minpos = {x = pos.x - 0.4, y = pos.y - 0.4, z = pos.z - 0.4},
			maxpos = {x = pos.x + 0.4, y = pos.y + 0.4, z = pos.z + 0.4},
			minvel = {x = -0.02, y = -0.02, z = -0.02},
			maxvel = {x = 0.02, y = 0.02, z = 0.02},
			minexptime = 2,
			maxexptime = 8,
			minsize = 0.25,
			maxsize = 0.5,
			glow = -4
		})
end

nodecore.register_limited_abm({
		label = "Scaling Decay (Root)",
		interval = 5,
		chance = 1,
		limited_max = 100,
		nodenames = {modname .. ":root"},
		action = function(pos)
			if (not findrel(pos, solid)) or (not anyclosenough(pos)) then
				return minetest.remove_node(pos)
			end
			return sparkle(pos)
		end
	})

nodecore.register_limited_abm({
		label = "Scaling Decay (Branch)",
		interval = 5,
		chance = 1,
		limited_max = 100,
		nodenames = {modname .. ":branch"},
		action = function(pos)
			local meta = minetest.get_meta(pos)
			local root = meta:get_string("root")
			if (not root) or (root == "") then
				return minetest.remove_node(pos)
			end
			root = minetest.string_to_pos(root)
			if (minetest.get_node(root).name ~= modname .. ":root")
			or (not anyclosenough(pos)) then
				return minetest.remove_node(pos)
			end
		end
	})

nodecore.register_limited_abm({
		label = "Scaling Decay (Floor)",
		interval = 5,
		chance = 1,
		limited_max = 100,
		nodenames = {modname .. ":floor"},
		action = function(pos)
			if (not solid({x = pos.x, y = pos.y - 1, z = pos.z}))
			or (not anyclosenough(pos)) then
				return minetest.remove_node(pos)
			end
		end
	})

local function addbranch(pos, dx, dy, dz)
	local npos = {x = pos.x + dx, y = pos.y + dy, z = pos.z + dz}
	if minetest.get_node(npos).name ~= "air" then return end
	minetest.set_node(npos, {name = modname .. ":branch"})
	minetest.get_meta(npos):set_string("root", minetest.pos_to_string(pos))
end

local function addanchor(pos)
	local rel = findrel(pos, solid)
	if rel then
		minetest.set_node(pos, {name = modname .. ":root"})
		sparkle(pos)
		addbranch(pos, 0, -1, 0)
		if rel == "ceil" then
			addbranch(pos, 1, -1, 0)
			addbranch(pos, -1, -1, 0)
			addbranch(pos, 0, -1, 1)
			addbranch(pos, 0, -1, -1)
		end
	elseif solid({x = pos.x, y = pos.y - 1, z = pos.z}) then
		minetest.set_node(pos, {name = modname .. ":floor"})
	end
end

local cache = {}

local function cacheclean()
	local exp = minetest.get_us_time() - 10 * 1000000
	minetest.after(10, cacheclean)
	for _, pc in pairs(cache) do
		for pkey, pp in pairs(pc) do
			if (pp.last or 0) < exp then
				pc[pkey] = nil
			end
		end
	end
end
cacheclean()

local function hit(pos, player)
	local nn = minetest.get_node(pos).name
	if nn ~= "air" and nn ~= modname .. ":branch" then return end
	local pname = player:get_player_name()
	local pc = cache[pname]
	if not pc then
		pc = {}
		cache[pname] = pc
	end
	local key = minetest.pos_to_string(pos)
	local pp = pc[key]
	if not pp then
		pp = {}
		pc[key] = pp
	end
	pp.last = minetest.get_us_time()
	pp.hits = (pp.hits or 0) + 1
	if pp.hits >= 5 then
		pc[key] = nil
		return addanchor(pos)
	end
end

local function scanplayer(player)
	local pos = player:get_pos()
	pos.y = pos.y + player:get_properties().eye_height
	local dir = player:get_look_dir()
	dir.x = dir.x + nodecore.boxmuller() / 3
	dir.y = dir.y + nodecore.boxmuller() / 3
	dir.z = dir.z + nodecore.boxmuller() / 3
	dir = vector.multiply(dir, math_random() * 5)
	for pointed in minetest.raycast(pos, vector.add(pos, dir)) do
		if pointed.type == "node" then return hit(pointed.above, player) end
	end
end

local function scan()
	minetest.after(0.25, scan)
	for _, player in pairs(minetest.get_connected_players()) do
		local ctl = player:get_player_control()
		if not ctl.right and not ctl.left and not ctl.down and not ctl.up
		and not ctl.LMB and not ctl.RBM then
			scanplayer(player)
		end
	end
end
scan()
